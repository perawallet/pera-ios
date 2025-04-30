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

//   HDWalletStorageTests.swift

import XCTest
import KeychainAccess

@testable import pera_staging

final class HDWalletStorageTests: XCTestCase {
    var keychain: Keychain!
    var sut: HDWalletStorage!
    var mockDataObject = "mocked data".data(using: .utf8)!
    
    override func setUp() {
        super.setUp()
        keychain = Keychain(service: "com.test.hdwallet")
        sut = HDWalletStorage(keychain: keychain)
    }
    
    override func tearDown() {
        try? keychain.removeAll()
        keychain = nil
        sut = nil
        super.tearDown()
    }
    
    func testSaveAndRetrieveWalletSuccessfully() throws {
        // Given
        let wallet = HDWalletSeed(id: "wallet1", entropy: HDWalletUtils.generate256BitEntropy())

        // When
        try sut.save(wallet: wallet)
        let retrievedWallet = try sut.wallet(id: "wallet1")

        // Then
        XCTAssertNotNil(retrievedWallet)
        XCTAssertEqual(retrievedWallet?.id, wallet.id)
    }
    
    func testRetrieveNonExistentWalletReturnsNil() throws {
        // When
        let retrievedWallet = try sut.wallet(id: "nonexistent_wallet")

        // Then
        XCTAssertNil(retrievedWallet)
    }
    
    func testDeleteWalletAndEnsureItsGone() throws {
        // Given
        let wallet = HDWalletSeed(id: "wallet2", entropy: HDWalletUtils.generate256BitEntropy())
        try sut.save(wallet: wallet)

        // When
        try sut.deleteWallet(id: "wallet2")
        let retrievedWallet = try sut.wallet(id: "wallet2")

        // Then
        XCTAssertNil(retrievedWallet)
    }
    
    func testSaveAndRetrieveAddressSuccessfully() throws {
        // Given
        let address = HDWalletAddress(walletId: "wallet3", address: "123456789", publicKey: mockDataObject, privateKey: mockDataObject)

        // When
        try sut.save(address: address)
        let retrievedAddress = try sut.address(walletId: "wallet3", address: "123456789")

        // Then
        XCTAssertNotNil(retrievedAddress)
        XCTAssertEqual(retrievedAddress?.walletId, address.walletId)
        XCTAssertEqual(retrievedAddress?.address, address.address)
    }
    
    func testRetrieveNonExistentAddressReturnsNil() throws {
        // When
        let retrievedAddress = try sut.address(walletId: "wallet4", address: "nonexistent_addr")

        // Then
        XCTAssertNil(retrievedAddress)
    }
    
    func testRetrieveAllAddressesForWallet() throws {
        // Given
        let address1 = HDWalletAddress(walletId: "wallet5", address: "mockAddress1", publicKey: mockDataObject, privateKey: mockDataObject)
        let address2 = HDWalletAddress(walletId: "wallet5", address: "mockAddress2", publicKey: mockDataObject, privateKey: mockDataObject)
        let address3 = HDWalletAddress(walletId: "wallet5", address: "mockAddress3", publicKey: mockDataObject, privateKey: mockDataObject)
        let address4 = HDWalletAddress(walletId: "wallet6", address: "mockAddress4", publicKey: mockDataObject, privateKey: mockDataObject) // different wallet

        try sut.save(address: address1)
        try sut.save(address: address2)
        try sut.save(address: address3)
        try sut.save(address: address4)

        // When
        let retrievedAddresses = try sut.addresses(walletId: "wallet5")

        // Then
        XCTAssertEqual(retrievedAddresses.count, 3)
        XCTAssertTrue(retrievedAddresses.contains { $0.address == "mockAddress1" })
        XCTAssertTrue(retrievedAddresses.contains { $0.address == "mockAddress2" })
        XCTAssertTrue(retrievedAddresses.contains { $0.address == "mockAddress3" })
        XCTAssertFalse(retrievedAddresses.contains { $0.address == "mockAddress4" })
    }
    
    func testDeleteAddressAndEnsureItsGone() throws {
        // Given
        let address = HDWalletAddress(walletId: "wallet7", address: "mockAddress1", publicKey: mockDataObject, privateKey: mockDataObject)
        try sut.save(address: address)

        // When
        try sut.deleteAddress(walletId: "wallet7", address: "mockAddress1")
        let retrievedAddress = try sut.address(walletId: "wallet7", address: "mockAddress1")

        // Then
        XCTAssertNil(retrievedAddress)
    }
    
    func testRetrieveCorruptedWalletDataThrowsError() throws {
        // Given
        let corruptedData = Data([0x00, 0x01, 0x02, 0x03]) // Create corrupted data
        try keychain.set(corruptedData, key: "wallet.wallet8") // Insert corrupted data

        // When
        XCTAssertThrowsError(try sut.wallet(id: "wallet8")) { error in
            // Then
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testRetrieveCorruptedAddressDataThrowsError() throws {
        // Given
        let corruptedData = Data([0xFF, 0xAA, 0xBB, 0xCC]) // Create corrupted data
        try keychain.set(corruptedData, key: "address.wallet9.mockAddress1") // Insert corrupted data

        // When
        XCTAssertThrowsError(try sut.address(walletId: "wallet9", address: "mockAddress1")) { error in
            // Then
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testEnsureWalletKeysAreUnique() throws {
        // Given
        let wallet1 = HDWalletSeed(id: "wallet10", entropy: HDWalletUtils.generate256BitEntropy())
        let wallet2 = HDWalletSeed(id: "wallet11", entropy: HDWalletUtils.generate256BitEntropy())

        // When
        try sut.save(wallet: wallet1)
        try sut.save(wallet: wallet2)

        // Then
        let retrievedWallet1 = try sut.wallet(id: "wallet10")
        let retrievedWallet2 = try sut.wallet(id: "wallet11")

        XCTAssertNotNil(retrievedWallet1)
        XCTAssertNotNil(retrievedWallet2)
        XCTAssertNotEqual(retrievedWallet1?.id, retrievedWallet2?.id)
    }
    
    func testEnsureAddressKeysAreUnique() throws {
        // Given
        let address1 = HDWalletAddress(walletId: "wallet12", address: "mockAddress1", publicKey: mockDataObject, privateKey: mockDataObject)
        let address2 = HDWalletAddress(walletId: "wallet12", address: "mockAddress2", publicKey: mockDataObject, privateKey: mockDataObject)

        // When
        try sut.save(address: address1)
        try sut.save(address: address2)

        // Then
        let retrievedAddresses = try sut.addresses(walletId: "wallet12")

        XCTAssertEqual(retrievedAddresses.count, 2)
        XCTAssertTrue(retrievedAddresses.contains { $0.address == "mockAddress1" })
        XCTAssertTrue(retrievedAddresses.contains { $0.address == "mockAddress2" })
    }
    
    func testEmptyKeychainReturnsEmptyWalletList() throws {
        // When
        let retrievedWallet = try sut.wallet(id: "wallet13")

        // Then
        XCTAssertNil(retrievedWallet)
    }
    
    func testEmptyKeychainReturnsEmptyAddressList() throws {
        // When
        let retrievedAddresses = try sut.addresses(walletId: "wallet14")

        // Then
        XCTAssertEqual(retrievedAddresses.count, 0)
    }
}
