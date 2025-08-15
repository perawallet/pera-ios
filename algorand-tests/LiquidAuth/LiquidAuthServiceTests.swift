// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
import CryptoKit
import Scout
import MnemonicSwift
import Foundation
import deterministicP256_swift
import x_hd_wallet_api
@testable import pera_staging
@testable import pera_wallet_core

final class LiquidAuthServiceTests: XCTestCase {
    let TEST_PASSPHRASE = "cable wrestle polar excite crop excite must screen regret kit burst charge glue solid banner mutual unveil left craft bounce aim engine tomorrow wrap"
    var mockPassKeyService: MockPassKeyService!
    var mockFeatureFlagService: MockFeatureFlagService!
    var mockLiquidAuthSDK: MockLiquidAuthSDKAPI!
    var mockHDWalletSDK: ScoutMockHDWalletSDK!
    var service: LiquidAuthService!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        mockPassKeyService = MockPassKeyService()
        mockFeatureFlagService = MockFeatureFlagService()
        mockLiquidAuthSDK = MockLiquidAuthSDKAPI()
        mockHDWalletSDK = ScoutMockHDWalletSDK()

        service = LiquidAuthService(
            passKeyService: mockPassKeyService,
            featureFlagService: mockFeatureFlagService,
            liquidAuthSDK: mockLiquidAuthSDK
        )
    }

    override func tearDown() {
        mockPassKeyService = nil
        mockFeatureFlagService = nil
        mockLiquidAuthSDK = nil
        service = nil
        super.tearDown()
    }

    func test_handleAuthRequest_returnsError_whenFeatureFlagDisabled() async {
        mockFeatureFlagService.expect.isEnabled(flag: equalTo(FeatureFlag.liquidAuthEnabled)).to(`return`(false))

        let response = await service.handleAuthRequest(request: .init(origin: "origin.com", requestId: "req123"))

        XCTAssertEqual(response.error, "liquid-auth-not-implemented")
        mockFeatureFlagService.verify()
    }

    func test_handleAuthRequest_returnsError_whenNoAccount() async {
        mockFeatureFlagService.expect.isEnabled(flag: equalTo(FeatureFlag.liquidAuthEnabled)).to(`return`(true))
        let result: [AccountInformation] = []
        mockPassKeyService.expect.getSigningAccounts().to(`return`(result))

        let response = await service.handleAuthRequest(request: .init(origin: "origin.com", requestId: "req123"))

        XCTAssertEqual(response.error, "liquid-auth-no-account-found")
        mockFeatureFlagService.verify()
        mockPassKeyService.verify()
    }

    func test_handleAuthRequest_triggersAuthenticate_whenPassKeyExists() async {
        let detail = HDWalletAddressDetail(walletId: "ABC", account: 0, change: 0, keyIndex: 0)
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let info = AccountInformation(address: address.address, name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)

        mockFeatureFlagService.expect.isEnabled(flag: equalTo(FeatureFlag.liquidAuthEnabled)).to(`return`(true))
        mockPassKeyService.expect.getSigningAccounts().to(`return`([info]))
        mockPassKeyService.expect.getSigningSDK(account: equalTo(info)).to(`return`(mockHDWalletSDK))
        mockPassKeyService.expect.hasPassKey(origin: equalTo("origin.com"), username: equalTo(address.address)).to(`return`(true))
        
        mockHDWalletSDK.expect.rawSign(draft: any()).to(`return`("authData".data(using: .utf8)))

        let keyPair = try! getPrivateKey(origin: "origin.com")
        let authResponse = PassKeyAuthenticationResponse(credentialId: "cred", address: address.address, keyPair: keyPair)
        mockPassKeyService.expect.getAuthenticationData(request: any()).to(`return`(authResponse))

        mockLiquidAuthSDK.expect.postAssertionOptions(origin: any(), credentialId: any()).to(`return`(try! JSONSerialization.data(withJSONObject: [
            "challenge": Data("challenge".utf8).base64EncodedString(),
            "rpId": "origin.com"
        ])))
        mockLiquidAuthSDK.expect.decodeBase64UrlToJSON(any()).to(`return`(nil))
        mockLiquidAuthSDK.expect.decodeBase64Url(any()).to(`return`("challenge".data(using: .utf8)))
        mockLiquidAuthSDK.expect.getAssertionObject(rpIdHash: any(), userPresent: equalTo(true), userVerified: equalTo(true),
                                                    backupEligible: equalTo(false), backupState: equalTo(false), signCount: any()).to(`return`("authData".data(using: .utf8)))
        mockLiquidAuthSDK.expect.postAssertionResult(origin: equalTo("origin.com"), credential: any(), liquidExt: any()).to(`return`("{}".data(using: .utf8)))

        let response = await service.handleAuthRequest(request: .init(origin: "origin.com", requestId: "req123"))

        XCTAssertNil(response.error)
        XCTAssertNotNil(response.credentialId)

        mockFeatureFlagService.verify()
        mockPassKeyService.verify()
        mockLiquidAuthSDK.verify()
        mockHDWalletSDK.verify()
    }
    
    func test_handleAuthRequest_triggersRegister_whenPassKeyDoesNotExist() async {
        let credentialId = Data("cred".utf8)
        let keyPair = try! getPrivateKey(origin: "origin.com")
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let detail = HDWalletAddressDetail(walletId: "ABC", account: 0, change: 0, keyIndex: 0)
        let info = AccountInformation(address: address.address, name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)
        
        mockFeatureFlagService.expect.isEnabled(flag: equalTo(FeatureFlag.liquidAuthEnabled)).to(`return`(true))
        mockPassKeyService.expect.getSigningAccounts().to(`return`([info]))
        mockPassKeyService.expect.getSigningSDK(account: equalTo(info)).to(`return`(mockHDWalletSDK))
        mockPassKeyService.expect.hasPassKey(origin: equalTo("origin.com"), username: equalTo(address.address)).to(`return`(false))
        mockPassKeyService.expect.createAndSavePassKey(
            request: any()
        ).to(`return`(PassKeyCreationResponse(credentialId: credentialId, address: address.address, keyPair: keyPair)))
        mockLiquidAuthSDK.expect.decodeBase64UrlToJSON(any()).to(`return`(nil))
        
        mockHDWalletSDK.expect.rawSign(draft: any()).to(`return`("authData".data(using: .utf8)))

        // simulate attestation options call
        let challenge = Data("challenge".utf8)
        let challengeBase64 = challenge.base64EncodedString()

        mockLiquidAuthSDK.expect.postAttestationOptions(origin: equalTo("origin.com"), username: equalTo(address.address)).to(`return`(try! JSONSerialization.data(withJSONObject: [
            "challenge": Data("challenge".utf8).base64EncodedString(),
            "rpId": "origin.com"
        ])))

        mockLiquidAuthSDK.expect.decodeBase64Url(equalTo(challengeBase64)).to(`return`(challenge))
        mockLiquidAuthSDK.expect.getAttestationObject(credentialId: equalTo(credentialId), keyPair: any(), rpIdHash: any()).to(`return`(Data("attestation".utf8)))
        mockLiquidAuthSDK.expect.postAttestationResult(origin: equalTo("origin.com"), credential: any(), liquidExt: any()).to(`return`(Data()))

        let request = LiquidAuthRequest(origin: "origin.com", requestId: "req123")
        let response = await service.handleAuthRequest(request: request)

        XCTAssertNil(response.error)
        XCTAssertEqual(response.credentialId, credentialId.base64URLEncodedString())

        mockFeatureFlagService.verify()
        mockPassKeyService.verify()
        mockLiquidAuthSDK.verify()
        mockHDWalletSDK.verify()
    }

    func test_getRequestForURL_returnsNil_whenSchemeInvalid() {
        let url = URL(string: "https://example.com?requestId=req123")!
        let result = LiquidAuthService.getRequestForURL(url)
        XCTAssertNil(result)
    }

    func test_getRequestForURL_returnsRequest_whenValid() {
        let url = URL(string: "liquid://example.com?requestId=req123")!
        let result = LiquidAuthService.getRequestForURL(url)
        XCTAssertEqual(result?.origin, "example.com")
        XCTAssertEqual(result?.requestId, "req123")
    }
    
    private func getPrivateKey(origin: String) throws -> P256.Signing.PrivateKey {
        let phrase = "youth clog use limit else hub select cause digital oven stand bike alarm ring phone remain trigger essay royal tortoise bless goose forum reflect"
        let seed = try Mnemonic.deterministicSeedString(from: phrase)
        guard let ed25519Wallet = XHDWalletAPI(seed: seed) else {
          throw NSError(domain: "Wallet creation failed", code: -1, userInfo: nil)
        }

        let pk = try ed25519Wallet.keyGen(context: KeyContext.Address, account: 0, change: 0, keyIndex: 0)
        let address = try encodeAddress(bytes: pk)

        let dp256 = DeterministicP256()
        let derivedMainKey = try dp256.genDerivedMainKeyWithBIP39(phrase: phrase)
        let p256KeyPair = dp256.genDomainSpecificKeyPair(derivedMainKey: derivedMainKey, origin: origin, userHandle: address)
        return p256KeyPair
    }
    
    private func encodeAddress(bytes: Data) throws -> String {
      let lenBytes = 32
      let checksumLenBytes = 4
      let expectedStrEncodedLen = 58

      // compute sha512/256 checksum
      let hash = bytes.sha256()
      let hashedAddr = hash[..<lenBytes] // Take the first 32 bytes

      // take the last 4 bytes of the hashed address, and append to original bytes
      let checksum = hashedAddr[(hashedAddr.count - checksumLenBytes)...]
      let checksumAddr = bytes + checksum

      // encodeToMsgPack addr+checksum as base32 and return. Strip padding.
        let res = checksumAddr.base32EncodedString.trimmingCharacters(in: ["="])
      if res.count != expectedStrEncodedLen {
        throw NSError(
          domain: "",
          code: 0,
          userInfo: [NSLocalizedDescriptionKey: "unexpected address length \(res.count)"]
        )
      }
      return res
    }
                                                        
    private func generateSeed() -> HDWalletSeed {
        guard let seed = HDWalletUtils.generateSeed(fromMnemonic: TEST_PASSPHRASE),
              let entropy = HDWalletUtils.generateEntropy(fromMnemonic: TEST_PASSPHRASE) else {
            fatalError("Failed to generate entropy")
        }
        return HDWalletSeed(id: seed.toHexString(), entropy: entropy)
    }
    
    private func generateAddress(seed: HDWalletSeed) -> HDWalletAddress {
        let sdk = HDWalletSDKImp(seed: seed.id)
        let service = HDWalletService(sdk: sdk)
        return try! service.generateAddress(for: seed, at: 0)
    }
}

