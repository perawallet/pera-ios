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

//   HDWalletTransactionSignerTests.swift

import Foundation
import x_hd_wallet_api
import Testing
@testable import pera_staging

@Suite("HDWalletTransactionSigner Tests")
struct HDWalletTransactionSignerTests {
    
    @Test("Sign transaction with valid input should succeed")
    func testSignTransactionWithValidInput() async throws {
        // Given
        let (signer, mockSDK, wallet) = createSigner()
        let transaction = Data("test transaction".utf8)
        let addressDetail = HDWalletAddressDetail(
            walletId: wallet.id,
            account: 0,
            change: 0,
            keyIndex: 0,
            derivationType: .peikert
        )
        let expectedSignature = Data("signed transaction".utf8)
        mockSDK.signAlgorandTransactionResult = expectedSignature
        
        // When
        let signedTransaction = try signer.signTransaction(transaction, with: addressDetail)
        
        // Then
        #expect(signedTransaction == expectedSignature)
        #expect(mockSDK.lastSignedTransaction?.prefixEncodedTx == transaction)
        #expect(mockSDK.lastSignedTransaction?.account == addressDetail.account)
        #expect(mockSDK.lastSignedTransaction?.change == addressDetail.change)
        #expect(mockSDK.lastSignedTransaction?.keyIndex == addressDetail.keyIndex)
        #expect(mockSDK.lastSignedTransaction?.derivationType == addressDetail.derivationType)
    }
    
    @Test("Sign transaction with invalid SDK should throw error")
    func testSignTransactionWithInvalidSDK() async throws {
        // Given
        let (signer, _, wallet) = createSigner()
        signer.sdk = nil
        let transaction = Data("test transaction".utf8)
        let addressDetail = HDWalletAddressDetail(
            walletId: wallet.id,
            account: 0,
            change: 0,
            keyIndex: 0,
            derivationType: .peikert
        )
        
        // When/Then
        do {
            _ = try signer.signTransaction(transaction, with: addressDetail)
            throw TestFailure("Expected error to be thrown")
        } catch let error as HDWalletError {
            #expect(error == .invalidSeed)
        }
    }
    
    @Test("Sign transaction when SDK throws should propagate error")
    func testSignTransactionWhenSDKThrows() async throws {
        // Given
        let (signer, mockSDK, wallet) = createSigner()
        let transaction = Data("test transaction".utf8)
        let addressDetail = HDWalletAddressDetail(
            walletId: wallet.id,
            account: 0,
            change: 0,
            keyIndex: 0,
            derivationType: .peikert
        )
        let expectedError = NSError(domain: "test", code: 1)
        mockSDK.signAlgorandTransactionError = expectedError
        
        // When/Then
        do {
            _ = try signer.signTransaction(transaction, with: addressDetail)
            throw TestFailure("Expected error to be thrown")
        } catch let error as HDWalletError {
            if case .sdkError(let message) = error {
                #expect(message == expectedError.localizedDescription)
            } else {
                throw TestFailure("Unexpected error type: \(error)")
            }
        }
    }
    
    @Test("Sign multiple transactions with valid input should succeed")
    func testSignMultipleTransactionsWithValidInput() async throws {
        // Given
        let (signer, mockSDK, wallet) = createSigner()
        let transactions = [
            Data("transaction1".utf8),
            Data("transaction2".utf8)
        ]
        let addressDetail = HDWalletAddressDetail(
            walletId: wallet.id,
            account: 0,
            change: 0,
            keyIndex: 0,
            derivationType: .peikert
        )
        let expectedSignatures = [
            Data("signed1".utf8),
            Data("signed2".utf8)
        ]
        mockSDK.signAlgorandTransactionResults = expectedSignatures
        
        // When
        let signedTransactions = try signer.signTransactions(transactions, with: addressDetail)
        
        // Then
        #expect(signedTransactions.count == transactions.count)
        #expect(mockSDK.signedTransactions.count == transactions.count)
        
        for (index, transaction) in transactions.enumerated() {
            #expect(signedTransactions[index] == expectedSignatures[index])
            #expect(mockSDK.signedTransactions[index].prefixEncodedTx == transaction)
        }
    }
    
    @Test("Verify signature with valid input should return true")
    func testVerifySignatureWithValidInput() async throws {
        // Given
        let (signer, mockSDK, _) = createSigner()
        let signature = Data("test signature".utf8)
        let message = Data("test message".utf8)
        let publicKey = Data("test public key".utf8)
        mockSDK.verifySignatureResult = true
        
        // When
        let isValid = signer.verifySignature(signature, message: message, publicKey: publicKey)
        
        // Then
        #expect(isValid)
        #expect(mockSDK.lastVerifiedSignature?.signature == signature)
        #expect(mockSDK.lastVerifiedSignature?.message == message)
        #expect(mockSDK.lastVerifiedSignature?.publicKey == publicKey)
    }
    
    @Test("Verify signature with invalid SDK should return false")
    func testVerifySignatureWithInvalidSDK() async throws {
        // Given
        let (signer, _, _) = createSigner()
        signer.sdk = nil
        let signature = Data("test signature".utf8)
        let message = Data("test message".utf8)
        let publicKey = Data("test public key".utf8)
        
        // When
        let isValid = signer.verifySignature(signature, message: message, publicKey: publicKey)
        
        // Then
        #expect(!isValid)
    }
    
    // MARK: - Helper Methods
    
    private func createSigner() -> (HDWalletTransactionSigner, MockHDWalletSDK, HDWalletSeed) {
        let entropy = Data(repeating: 0x01, count: 32)
        let wallet = HDWalletSeed(entropy: entropy)
        let mockSDK = MockHDWalletSDK(seed: entropy.toHexString())!
        let signer = HDWalletTransactionSigner(wallet: wallet)
        signer.sdk = mockSDK
        return (signer, mockSDK, wallet)
    }
}

// MARK: - Test Helpers

struct TestFailure: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

// MARK: - Mock HDWalletSDK

private class MockHDWalletSDK: HDWalletSDK {
    var signAlgorandTransactionResult: Data?
    var signAlgorandTransactionResults: [Data] = []
    var signAlgorandTransactionError: Error?
    var verifySignatureResult = false
    
    var lastSignedTransaction: HDWalletSignAlgoTransactionDraft?
    var signedTransactions: [HDWalletSignAlgoTransactionDraft] = []
    var lastVerifiedSignature: HDWalletVerifySignatureDraft?
    
    required init?(seed: String) {
        // Always succeed in tests
    }
    
    func derivePublicChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        fatalError("Not implemented")
    }
    
    func derivePrivateChildNode(_ draft: HDWalletDeriveChildNodeDraft) throws -> Data {
        fatalError("Not implemented")
    }
    
    func deriveKey(_ draft: HDWalletDeriveKeyDraft) throws -> Data {
        fatalError("Not implemented")
    }
    
    func generateKey(_ draft: HDWalletKeyGenDraft) throws -> Data {
        fatalError("Not implemented")
    }
    
    func signAlgorandTransaction(_ draft: HDWalletSignAlgoTransactionDraft) throws -> Data {
        lastSignedTransaction = draft
        signedTransactions.append(draft)
        
        if let error = signAlgorandTransactionError {
            throw error
        }
        
        if !signedTransactions.isEmpty && !signAlgorandTransactionResults.isEmpty {
            return signAlgorandTransactionResults[signedTransactions.count - 1]
        }
        
        return signAlgorandTransactionResult ?? Data()
    }
    
    func signData(_ draft: HDWalletSignDataDraft) throws -> Data {
        fatalError("Not implemented")
    }
    
    func verifySignature(_ draft: HDWalletVerifySignatureDraft) -> Bool {
        lastVerifiedSignature = draft
        return verifySignatureResult
    }
    
    func validateData(_ data: Data, against metadata: SignMetadata) throws -> Bool {
        fatalError("Not implemented")
    }
    
    func performECDH(_ draft: HDWalletECDHDraft) throws -> Data {
        fatalError("Not implemented")
    }
}
