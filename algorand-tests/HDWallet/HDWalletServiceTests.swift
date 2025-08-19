// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   HDWalletServiceTests.swift

import XCTest
@testable import MnemonicSwift
@testable import pera_wallet_core
@testable import pera_staging
@testable import x_hd_wallet_api

final class HDWalletServiceTests: XCTestCase {
    var sut: HDWalletService!
    var mockSDK: HDWalletSDKMock!
    
    override func setUp() {
        super.setUp()
        mockSDK = HDWalletSDKMock(seed: "validSeed")
        sut = HDWalletService(sdk: mockSDK)
    }
    
    override func tearDown() {
        sut = nil
        mockSDK = nil
        super.tearDown()
    }
    
    // MARK: - Mnemonic Generation Tests
    
    func test_GenerateMnemonic_ShouldGenerate24Words() throws {
        // When
        let mnemonic = try sut.generateMnemonic()
        let words = mnemonic.split(separator: " ")
        
        // Then
        XCTAssertEqual(words.count, 24)
        // Verify that all words are in the BIP39 word list
        words.forEach { word in
            XCTAssertTrue(
                MnemonicLanguageType.english.words().contains(String(word)),
                "Word '\(word)' is not in BIP39 word list"
            )
        }
    }
    
    func test_GenerateMnemonic_ShouldGenerateValidBIP39Mnemonic() throws {
        // When
        let mnemonic = try sut.generateMnemonic()
        
        // Then
        // Verify that the mnemonic is valid according to BIP39
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: mnemonic))
        
        // Verify that we can generate a seed from it
        XCTAssertNoThrow(try Mnemonic.deterministicSeedBytes(from: mnemonic))
    }
    
    // MARK: - Wallet Creation Tests
    
    func test_CreateWallet_ShouldSucceed() throws {
        // Given
        let entropy = HDWalletUtils.generate256BitEntropy()
        
        // When
        let wallet = try sut.createWallet(from: entropy)
        
        // Then
        XCTAssertNotNil(wallet)
        XCTAssertEqual(wallet.entropy, entropy)
    }
    
    func test_CreateWallet_WithInvalidMnemonic_ShouldThrow() {
        // Given
        let invalidEntropy = Data()
        
        // Then
        XCTAssertThrowsError(try sut.createWallet(from: invalidEntropy))
    }
    
    // MARK: - Address Generation Tests
    
    func test_GenerateAddress_WithPeikertDerivation_ShouldSucceed() throws {
        // Given
        let entropy = HDWalletUtils.generate256BitEntropy()
        let wallet = HDWalletSeed(entropy: entropy)
        
        let expectedPublicKey = Data([7, 8, 9])
        let expectedPrivateKey = Data([10, 11, 12])
        mockSDK.generateKeyResult = .success(expectedPublicKey)
        mockSDK.deriveKeyResult = .success(expectedPrivateKey)
        
        // When
        let address = try sut.generateAddress(for: wallet, at: 0)
        
        // Then
        XCTAssertTrue(mockSDK.generateKeyCalled)
        XCTAssertTrue(mockSDK.deriveKeyCalled)
        
        let keyGenDraft = mockSDK.lastKeyGenDraft
        XCTAssertEqual(keyGenDraft?.account, 0)
        XCTAssertEqual(keyGenDraft?.change, 0)
        XCTAssertEqual(keyGenDraft?.keyIndex, 0)
        XCTAssertEqual(keyGenDraft?.derivationType, .peikert)
        
        let deriveKeyDraft = mockSDK.lastDeriveKeyDraft
        XCTAssertEqual(deriveKeyDraft?.bip44Path, [44, 283, 0, 0, 0].map { UInt32($0) })
        XCTAssertEqual(deriveKeyDraft?.isPrivate, true)
        XCTAssertEqual(deriveKeyDraft?.derivationType, .peikert)
        
        XCTAssertEqual(address.publicKey, expectedPublicKey)
        XCTAssertEqual(address.privateKey, expectedPrivateKey)
    }
    
    func test_GenerateAddress_WithKhovratovichDerivation_ShouldSucceed() throws {
        // Given
        let entropy = HDWalletUtils.generate256BitEntropy()
        let wallet = HDWalletSeed(entropy: entropy)
        
        let expectedPublicKey = Data([7, 8, 9])
        let expectedPrivateKey = Data([10, 11, 12])
        mockSDK.generateKeyResult = .success(expectedPublicKey)
        mockSDK.deriveKeyResult = .success(expectedPrivateKey)
        sut = HDWalletService(sdk: mockSDK, derivationType: .bip32)
        
        // When
        let address = try sut.generateAddress(for: wallet, at: 0)
        
        // Then
        XCTAssertTrue(mockSDK.generateKeyCalled)
        XCTAssertTrue(mockSDK.deriveKeyCalled)
        
        let keyGenDraft = mockSDK.lastKeyGenDraft
        XCTAssertEqual(keyGenDraft?.account, 0)
        XCTAssertEqual(keyGenDraft?.change, 0)
        XCTAssertEqual(keyGenDraft?.keyIndex, 0)
        XCTAssertEqual(keyGenDraft?.derivationType, .bip32)
        
        let deriveKeyDraft = mockSDK.lastDeriveKeyDraft
        XCTAssertEqual(deriveKeyDraft?.bip44Path, [44, 283, 0, 0, 0].map { UInt32($0) })
        XCTAssertEqual(deriveKeyDraft?.isPrivate, true)
        XCTAssertEqual(deriveKeyDraft?.derivationType, .bip32)
        
        XCTAssertEqual(address.publicKey, expectedPublicKey)
        XCTAssertEqual(address.privateKey, expectedPrivateKey)
    }
    
    func test_GenerateAddress_WithDefaultDerivation_ShouldUsePeikert() throws {
        // Given
        let entropy = HDWalletUtils.generate256BitEntropy()
        let wallet = HDWalletSeed(entropy: entropy)
        
        mockSDK.generateKeyResult = .success(Data())
        mockSDK.deriveKeyResult = .success(Data())
        
        // When
        _ = try sut.generateAddress(for: wallet, at: 0)
        
        // Then
        let keyGenDraft = mockSDK.lastKeyGenDraft
        XCTAssertEqual(keyGenDraft?.derivationType, .peikert)
        
        let deriveKeyDraft = mockSDK.lastDeriveKeyDraft
        XCTAssertEqual(deriveKeyDraft?.derivationType, .peikert)
    }
    
    func test_GenerateAddress_WithInvalidSeed_ShouldThrow() throws {
        // Given
        let entropy = HDWalletUtils.generate256BitEntropy()
        let wallet = HDWalletSeed(entropy: entropy)
        
        let expectedError = HDWalletError.sdkError("Key generation failed")
        mockSDK.generateKeyResult = .failure(expectedError)
        
        // Then
        XCTAssertThrowsError(try sut.generateAddress(for: wallet, at: 0))
    }
}
