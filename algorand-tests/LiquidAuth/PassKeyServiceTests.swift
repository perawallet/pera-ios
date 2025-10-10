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
import Scout
@testable import pera_staging
@testable import pera_wallet_core

final class PassKeyServiceTests: XCTestCase {
    let TEST_PASSPHRASE = "cable wrestle polar excite crop excite must screen regret kit burst charge glue solid banner mutual unveil left craft bounce aim engine tomorrow wrap"
    var service: PassKeyService!
    var mockHDWalletStorage: ScoutMockHDWalletStorage!
    var mockSession: MockSession!
    var mockLiquidAuthSDK: MockLiquidAuthSDKAPI!

    override func setUp() {
        super.setUp()
        mockHDWalletStorage = ScoutMockHDWalletStorage()
        mockSession = MockSession()
        mockLiquidAuthSDK = MockLiquidAuthSDKAPI()
        
        PassKey.fetchAll(entity: PassKey.entityName) { result in
            let result = PassKey.fetchAllSyncronous(entity: PassKey.entityName)
            
            switch result {
            case .result(let object):
                if object is PassKey {
                    (object as! PassKey).remove(entity: PassKey.entityName)
                }
            case .results(let objects):
                objects.filter({$0 is PassKey}).forEach({ ($0 as! PassKey).remove(entity: PassKey.entityName) })
            case .error:
                break
            }
        }
        
        service = PassKeyService(
            hdWalletStorage: mockHDWalletStorage,
            session: mockSession,
            liquidAuthSDK: mockLiquidAuthSDK
        )
    }

    override func tearDown() {
        service = nil
        mockHDWalletStorage = nil
        mockSession = nil
        mockLiquidAuthSDK = nil
        super.tearDown()
    }

    func test_getSigningAccounts_returnsAddresses() async throws {
        let detail = HDWalletAddressDetail(walletId: "ABC", account: 0, change: 0, keyIndex: 0)
        let info = AccountInformation(address: "addr", name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)
        let info2 = AccountInformation(address: "nothd", name: "My NonHD Account", isWatchAccount: false, isBackedUp: false)
        let expectedAccounts = [
            info2,
            info
        ]
        
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let user = User(accounts: expectedAccounts)
        mockSession.authenticatedUser = user
        mockHDWalletStorage.expect.address(walletId: equalTo(detail.walletId), address: equalTo(info.address)).to(`return`(address))
            
        let result = try await service.findAllSigningAccounts()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.address, info.address)
    }

    func test_createAndSavePassKey_success() async throws {
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let detail = HDWalletAddressDetail(walletId: address.walletId, account: 0, change: 0, keyIndex: 0)
        let info = AccountInformation(address: address.address, name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)
        let expectedAccounts = [
            info
        ]
        let user = User(accounts: expectedAccounts)
        mockSession.authenticatedUser = user
        mockHDWalletStorage.expect.address(walletId: equalTo(detail.walletId), address: equalTo(info.address)).to(`return`(address))
        mockHDWalletStorage.expect.wallet(id: equalTo(detail.walletId)).to(`return`(seed))
        
        let request = PassKeyCreationRequest(origin: "test_createAndSavePassKey_success.com", username: "myuser", userHandle: Data(hexStr: "ffff") ?? Data(), displayName: "TestPass")

        do {
            let response = try await service.createAndSavePassKey(request: request)
            XCTAssertEqual(response.address, address.address)
            XCTAssertNotNil(response.credentialId)
            XCTAssertNotNil(response.keyPair)
        } catch {
            XCTFail()
        }
    }

    func test_createAndSavePassKey_fails_whenAccountMissing() async throws {
        let user = User(accounts: [])
        mockSession.authenticatedUser = user

        let request = PassKeyCreationRequest(origin: "test_createAndSavePassKey_fails_whenAccountMissing.com", username: "myuser", userHandle: Data(hexStr: "ffff") ?? Data(), displayName: "test")

        do {
            let response = try await service.createAndSavePassKey(request: request)
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, String(localized: "liquid-auth-no-account-found"))
        }
    }

    func test_createAndSavePassKey_fails_whenPasskeyAlreadyExists() async throws {
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let detail = HDWalletAddressDetail(walletId: address.walletId, account: 0, change: 0, keyIndex: 0)
        let info = AccountInformation(address: address.address, name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)
        let expectedAccounts = [
            info
        ]
        let user = User(accounts: expectedAccounts)
        mockSession.authenticatedUser = user
        mockHDWalletStorage.expect.address(walletId: equalTo(detail.walletId), address: equalTo(info.address)).to(`return`(address))
        mockHDWalletStorage.expect.wallet(id: equalTo(detail.walletId)).to(`return`(seed))
        
        _ = try await service.createAndSavePassKey(request: .init(origin: "test_createAndSavePassKey_fails_whenPasskeyAlreadyExists.com", username: "myuser", userHandle: Data(hexStr: "ffff") ?? Data(), displayName: "test"))

        do {
            let _ = try await service.createAndSavePassKey(request: .init(origin: "test_createAndSavePassKey_fails_whenPasskeyAlreadyExists.com", username: "myuser", userHandle: Data(hexStr: "ffff") ?? Data(), displayName: "test"))
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, String(localized: "liquid-auth-passkey-already-exists"))
        }
    }

    func test_getAuthenticationData_success() async throws {
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let detail = HDWalletAddressDetail(walletId: address.walletId, account: 0, change: 0, keyIndex: 0)
        let info = AccountInformation(address: address.address, name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)
        let expectedAccounts = [
            info
        ]
        let user = User(accounts: expectedAccounts)
        mockSession.authenticatedUser = user
        mockHDWalletStorage.expect.address(walletId: equalTo(detail.walletId), address: equalTo(info.address)).to(`return`(address))
        mockHDWalletStorage.expect.address(walletId: equalTo(detail.walletId), address: equalTo(info.address)).to(`return`(address))
        mockHDWalletStorage.expect.wallet(id: equalTo(detail.walletId)).to(`return`(seed))
        mockHDWalletStorage.expect.wallet(id: equalTo(detail.walletId)).to(`return`(seed))
        _ = try await service.createAndSavePassKey(request: .init(origin: "test_getAuthenticationData_success.com", username: "myuser", userHandle: Data(hexStr: "ffff") ?? Data(), displayName: "test"))

        do {
            let response = try await service.makeAuthenticationData(request: .init(origin: "test_getAuthenticationData_success.com", username: "myuser"))
            XCTAssertEqual(response.address, address.address)
            XCTAssertNotNil(response.credentialId)
            XCTAssertNotNil(response.keyPair)
        } catch {
            XCTFail()
        }
    }

    func test_getAuthenticationData_fails_whenNoMatchingPasskey() async {
        let info = AccountInformation(address: "nothd", name: "My NonHD Account", isWatchAccount: false, isBackedUp: false)
        let expectedAccounts = [
            info
        ]
        let user = User(accounts: expectedAccounts)
        mockSession.authenticatedUser = user
        
        do {
            let response = try await service.makeAuthenticationData(request: .init(origin: "test_getAuthenticationData_fails_whenNoAccount.com", username: "myuser"))
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, String(localized: "liquid-auth-no-passkey-found"))
        }
    }

    func test_getAuthenticationData_fails_whenNoMatchingAccount() async {
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let user = User(accounts: [])
        mockSession.authenticatedUser = user
        
        // tamper passkey data
        PassKey.create(entity: PassKey.entityName, with: [
            PassKey.DBKeys.origin.rawValue: "test_getAuthenticationData_fails_whenNoMatchingAccount.com",
            PassKey.DBKeys.username.rawValue: address.address,
            PassKey.DBKeys.address.rawValue: address.address,
            PassKey.DBKeys.credentialId.rawValue: "fake_id",
        ])
        
        do {
            let response = try await service.makeAuthenticationData(request: .init(origin: "test_getAuthenticationData_fails_whenNoMatchingPasskey.com", username: "myuser"))
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, String(localized: "liquid-auth-no-passkey-found"))
        }
    }

    func test_getAuthenticationData_fails_whenPasskeyDoesNotMatchCredentialId() async throws {
        let seed = generateSeed()
        let address = generateAddress(seed: seed)
        let detail = HDWalletAddressDetail(walletId: address.walletId, account: 0, change: 0, keyIndex: 0)
        let info = AccountInformation(address: address.address, name: "My Account", isWatchAccount: false, isBackedUp: false, hdWalletAddressDetail: detail)
        let expectedAccounts = [
            info
        ]
        let user = User(accounts: expectedAccounts)
        mockSession.authenticatedUser = user
        mockHDWalletStorage.expect.address(walletId: equalTo(detail.walletId), address: equalTo(info.address)).to(`return`(address))
        mockHDWalletStorage.expect.wallet(id: equalTo(detail.walletId)).to(`return`(seed))
        
        // tamper passkey data
        PassKey.create(entity: PassKey.entityName, with: [
            PassKey.DBKeys.origin.rawValue: "test_getAuthenticationData_fails_whenPasskeyDoesNotMatchCredentialId.com",
            PassKey.DBKeys.username.rawValue: "myuser",
            PassKey.DBKeys.address.rawValue: address.address,
            PassKey.DBKeys.credentialId.rawValue: "fake_id",
        ])
        
        do {
            let response = try await service.makeAuthenticationData(request: .init(origin: "test_getAuthenticationData_fails_whenPasskeyDoesNotMatchCredentialId.com", username: "myuser"))
            XCTFail()
        } catch {
            XCTAssertEqual(error.localizedDescription, String(localized: "liquid-auth-invalid-passkey-found"))
        }
    }

    func test_hasPassKey_returnsTrueWhenExists() {
        PassKey.create(entity: PassKey.entityName, with: [
            PassKey.DBKeys.origin.rawValue: "test_hasPassKey_returnsTrueWhenExists.com",
            PassKey.DBKeys.username.rawValue: "user",
            PassKey.DBKeys.address.rawValue: "address",
            PassKey.DBKeys.credentialId.rawValue: "fake_id",
        ])

        let result = service.hasPassKey(origin: "test_hasPassKey_returnsTrueWhenExists.com", username: "user")
        XCTAssertTrue(result)
    }

    func test_hasPassKey_returnsFalseWhenNotExists() {
        let result = service.hasPassKey(origin: "test_hasPassKey_returnsFalseWhenNotExists.com", username: "user")
        XCTAssertFalse(result)
    }

    func test_deletePassKeys_removesMatchingKeys() {
        PassKey.create(entity: PassKey.entityName, with: [
            PassKey.DBKeys.origin.rawValue: "test_deletePassKeys_removesMatchingKeys.com",
            PassKey.DBKeys.username.rawValue: "user",
            PassKey.DBKeys.address.rawValue: "address",
            PassKey.DBKeys.credentialId.rawValue: "fake_id",
        ])
        
        let exists = service.hasPassKey(origin: "test_deletePassKeys_removesMatchingKeys.com", username: "user")
        XCTAssertTrue(exists)

        service.deletePassKeysForOriginAndUsername(origin: "test_deletePassKeys_removesMatchingKeys.com", username: "user")
        
        let exists2 = service.hasPassKey(origin: "test_deletePassKeys_removesMatchingKeys.com", username: "user")
        XCTAssertFalse(exists2)
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


