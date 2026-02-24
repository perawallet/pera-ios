// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountTransactionHandler.swift

import pera_wallet_core

final class JointAccountTransactionHandler {
    
    enum TransactionType {
        case sendAlgos(draft: AlgosTransactionSendDraft)
        case rekey(draft: RekeyTransactionSendDraft)
    }
    
    enum HandlerError: Error {
        case noSignersAccounts
        case unknown
    }
    
    struct Metadata {
        let proposerAddress: String
        let apiResponse: ProposeSignResponse
    }
    
    // MARK: - Properties
    
    private let accountsService: AccountsServiceable
    
    // MARK: - Initialisers
    
    init(accountsService: AccountsServiceable) {
        self.accountsService = accountsService
    }
    
    // MARK: - Actions
    
    @MainActor
    func handleTransaction(jointAccount: Account, type: TransactionType, sharedDataController: SharedDataController, transactionController: TransactionController) async throws -> Metadata {
        
        try await withCheckedThrowingContinuation { continuation in
            
            sharedDataController.getTransactionParams(isCacheEnabled: true) { [weak self] in
                
                guard let self else {
                    continuation.resume(throwing: HandlerError.unknown)
                    return
                }
                
                switch $0 {
                case let .success(transactionParameters):
                    
                    let transactions = [transactionData(transactionType: type, parameters: transactionParameters)]
                    let participants = jointAccount.jointAccountParticipants ?? []
                    let signersAccounts = participants.compactMap { self.accountsService.account(address: $0) }
                    
                    guard let proposerAddress = signersAccounts.first?.address else {
                        continuation.resume(throwing: HandlerError.noSignersAccounts)
                        return
                    }
                    
                    let rawTransactionLists = transactions.map { $0.map { $0.base64EncodedString() }}
                    let responses = signersAccounts.map { self.signRequestResponse(signerAccount: $0, transactions: transactions, transactionController: transactionController) }
                    
                    Task {
                        do {
                            let result = try await self.accountsService.createJointAccountSignTransactionRequest(
                                jointAccountAddress: jointAccount.address,
                                proposerAddress: proposerAddress,
                                rawTransactionLists: rawTransactionLists,
                                responses: responses
                            )
                            let metadata = Metadata(proposerAddress: proposerAddress, apiResponse: result)
                            continuation.resume(returning: metadata)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Data Handlers
    
    private func transactionData(transactionType: TransactionType, parameters: TransactionParams) -> [Data] {
        builder(transactionType: transactionType, parameters: parameters)
            .composeData()?
            .map(\.transaction) ?? []
    }
    
    private func builder(transactionType: TransactionType, parameters: TransactionParams) -> TransactionDataBuildable {
        switch transactionType {
        case let .rekey(draft):
            RekeyTransactionDataBuilder(params: parameters, draft: draft)
        case let .sendAlgos(draft):
            AlgoTransactionDataBuilder(params: parameters, draft: draft, initialSize: nil)
        }
    }
    
    private func signRequestResponse(signerAccount: Account, transactions: [[Data]], transactionController: TransactionController) -> JointAccountSignRequestResponse {
       
       let signatures = transactions.map { $0.compactMap { transactionController.singature(signerAccount: signerAccount, transactionData: $0)?.base64EncodedString() }}
       
       return JointAccountSignRequestResponse(
          address: signerAccount.address,
          response: .signed,
          signatures: signatures,
          deviceId: nil
       )
    }
}
