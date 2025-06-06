// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AlgorandSDKTests.swift

import XCTest
@testable import pera_staging
@testable import x_hd_wallet_api

final class HDWalletSDKTests: XCTestCase {
    var sut: HDWalletSDKMock!
    
    override func setUp() {
        super.setUp()
        sut = HDWalletSDKMock(seed: "validSeed")
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_Init_WithValidSeed_ShouldInitializeSuccessfully() {
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.initWithSeedCalled)
        XCTAssertEqual(sut.seedProvided, "validSeed")
    }
    
    // MARK: - Derive Child Node Tests
    
    func test_DerivePublicChildNode_ShouldCallAPIWithCorrectParameters() throws {
        let draft = HDWalletDeriveChildNodeDraft(
            extendedKey: Data([1, 2, 3]),
            index: 0,
            derivationType: .peikert
        )
        
        let expectedData = Data([4, 5, 6])
        sut.derivePublicChildNodeResult = .success(expectedData)
        
        let result = try sut.derivePublicChildNode(draft)
        
        XCTAssertTrue(sut.derivePublicChildNodeCalled)
        XCTAssertEqual(sut.lastDeriveChildNodeDraft?.extendedKey, draft.extendedKey)
        XCTAssertEqual(sut.lastDeriveChildNodeDraft?.index, draft.index)
        XCTAssertEqual(sut.lastDeriveChildNodeDraft?.derivationType, draft.derivationType)
        XCTAssertEqual(result, expectedData)
    }
    
    func test_DerivePrivateChildNode_ShouldCallAPIWithCorrectParameters() throws {
        let draft = HDWalletDeriveChildNodeDraft(
            extendedKey: Data([1, 2, 3]),
            index: 0,
            derivationType: .peikert
        )
        
        let expectedData = Data([4, 5, 6])
        sut.derivePrivateChildNodeResult = .success(expectedData)
        
        let result = try sut.derivePrivateChildNode(draft)
        
        XCTAssertTrue(sut.derivePrivateChildNodeCalled)
        XCTAssertEqual(sut.lastDeriveChildNodeDraft?.extendedKey, draft.extendedKey)
        XCTAssertEqual(sut.lastDeriveChildNodeDraft?.index, draft.index)
        XCTAssertEqual(sut.lastDeriveChildNodeDraft?.derivationType, draft.derivationType)
        XCTAssertEqual(result, expectedData)
    }
    
    // MARK: - Key Generation Tests
    
    func test_GenerateKey_ShouldCallAPIWithCorrectParameters() throws {
        let draft = HDWalletKeyGenDraft(
            context: .address,
            account: 0,
            change: 0,
            keyIndex: 0,
            derivationType: .peikert
        )
        
        let expectedData = Data([4, 5, 6])
        sut.generateKeyResult = .success(expectedData)
        
        let result = try sut.generateKey(draft)
        
        XCTAssertTrue(sut.generateKeyCalled)
        XCTAssertEqual(sut.lastKeyGenDraft?.account, draft.account)
        XCTAssertEqual(sut.lastKeyGenDraft?.change, draft.change)
        XCTAssertEqual(sut.lastKeyGenDraft?.keyIndex, draft.keyIndex)
        XCTAssertEqual(sut.lastKeyGenDraft?.derivationType, draft.derivationType)
        XCTAssertEqual(result, expectedData)
    }
    
    // MARK: - Transaction Signing Tests
    
    func test_SignAlgorandTransaction_ShouldCallAPIWithCorrectParameters() throws {
        let draft = HDWalletSignAlgoTransactionDraft(
            context: .address,
            account: 0,
            change: 0,
            keyIndex: 0,
            prefixEncodedTx: Data([7, 8, 9]),
            derivationType: .peikert
        )
        
        let expectedData = Data([4, 5, 6])
        sut.signAlgorandTransactionResult = .success(expectedData)
        
        let result = try sut.signAlgorandTransaction(draft)
        
        XCTAssertTrue(sut.signAlgorandTransactionCalled)
        XCTAssertEqual(sut.lastSignAlgoTransactionDraft?.account, draft.account)
        XCTAssertEqual(sut.lastSignAlgoTransactionDraft?.change, draft.change)
        XCTAssertEqual(sut.lastSignAlgoTransactionDraft?.keyIndex, draft.keyIndex)
        XCTAssertEqual(sut.lastSignAlgoTransactionDraft?.prefixEncodedTx, draft.prefixEncodedTx)
        XCTAssertEqual(sut.lastSignAlgoTransactionDraft?.derivationType, draft.derivationType)
        XCTAssertEqual(result, expectedData)
    }
    
    // MARK: - Signature Verification Tests
    
    func test_VerifySignature_ShouldCallAPIWithCorrectParameters() {
        let draft = HDWalletVerifySignatureDraft(
            signature: Data([1, 2, 3]),
            message: Data([4, 5, 6]),
            publicKey: Data([7, 8, 9])
        )
        
        sut.verifySignatureResult = true
        
        let result = sut.verifySignature(draft)
        
        XCTAssertTrue(sut.verifySignatureCalled)
        XCTAssertEqual(sut.lastVerifySignatureDraft?.signature, draft.signature)
        XCTAssertEqual(sut.lastVerifySignatureDraft?.message, draft.message)
        XCTAssertEqual(sut.lastVerifySignatureDraft?.publicKey, draft.publicKey)
        XCTAssertTrue(result)
    }
    
    // MARK: - ECDH Tests
    
    func test_PerformECDH_ShouldCallAPIWithCorrectParameters() throws {
        let draft = HDWalletECDHDraft(
            context: .address,
            account: 0,
            change: 0,
            keyIndex: 0,
            otherPartyPub: Data([7, 8, 9]),
            meFirst: true,
            derivationType: .peikert
        )
        
        let expectedData = Data([4, 5, 6])
        sut.performECDHResult = .success(expectedData)
        
        let result = try sut.performECDH(draft)
        
        XCTAssertTrue(sut.performECDHCalled)
        XCTAssertEqual(sut.lastECDHDraft?.account, draft.account)
        XCTAssertEqual(sut.lastECDHDraft?.change, draft.change)
        XCTAssertEqual(sut.lastECDHDraft?.keyIndex, draft.keyIndex)
        XCTAssertEqual(sut.lastECDHDraft?.otherPartyPub, draft.otherPartyPub)
        XCTAssertEqual(sut.lastECDHDraft?.meFirst, draft.meFirst)
        XCTAssertEqual(sut.lastECDHDraft?.derivationType, draft.derivationType)
        XCTAssertEqual(result, expectedData)
    }
    
    // MARK: - Error Handling Tests
    
    func test_DerivePublicChildNode_WhenErrorOccurs_ShouldThrowError() {
        let draft = HDWalletDeriveChildNodeDraft(
            extendedKey: Data([1, 2, 3]),
            index: 0,
            derivationType: .peikert
        )
        
        let expectedError = HDWalletSDKError.sdkError("Test error")
        sut.derivePublicChildNodeResult = .failure(expectedError)
        
        XCTAssertThrowsError(try sut.derivePublicChildNode(draft)) { error in
            XCTAssertEqual(error as? HDWalletSDKError, expectedError)
        }
    }
} 
