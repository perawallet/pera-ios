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
        case sendAsset(draft: AssetTransactionSendDraft)
        case rekey(draft: RekeyTransactionSendDraft)
        case optIn(draft: AssetTransactionSendDraft)
        case optOut(draft: AssetTransactionSendDraft)
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
    func isConnectionWithLedgerRequired(jointAccount: Account) -> Bool {
        
        let signerAccount = accountsService.account(address: jointAccount.signerAddress)
        guard let participants = signerAccount?.jointAccountParticipants else { return false }
        let localParticipants = participants.compactMap { accountsService.account(address: $0) }
        let ledgerParticipants = localParticipants.filter { $0.hasLedgerDetail() }
        
        return !localParticipants.isEmpty && localParticipants.count == ledgerParticipants.count
    }
    
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
                    let subjectAccount: Account
                    
                    if jointAccount.authorization.isJointAccountRekeyed, let authAddress = jointAccount.authAddress, let authHolderAccount = accountsService.account(address: authAddress) {
                        subjectAccount = authHolderAccount
                    } else {
                        subjectAccount = jointAccount
                    }
                    
                    let participants = subjectAccount.jointAccountParticipants ?? []
                    
                    let signersAccounts: [Account]
                    let localAccounts = participants.compactMap { self.accountsService.account(address: $0) }
                    let normalLocalAcounts = localAccounts.filter { !$0.hasLedgerDetail() }
                    
                    if normalLocalAcounts.isEmpty, let ledgerAccount = localAccounts.first {
                        signersAccounts = [ledgerAccount]
                    } else {
                        signersAccounts = normalLocalAcounts
                    }
                    
                    guard let proposerAddress = signersAccounts.first?.address else {
                        continuation.resume(throwing: HandlerError.noSignersAccounts)
                        return
                    }
                    
                    let rawTransactionLists = transactions.map { $0.map { $0.base64EncodedString() }}
                    
                    Task {
                        var responses: [JointAccountSignRequestResponse] = []
                        
                        for account in signersAccounts {
                            let response = await self.signRequestResponse(signerAccount: account, transactions: transactions, transactionController: transactionController)
                            responses.append(response)
                        }
                        
                        do {
                            let result = try await self.accountsService.createJointAccountSignTransactionRequest(
                                jointAccountAddress: subjectAccount.address,
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
        case let .sendAlgos(draft):
            AlgoTransactionDataBuilder(params: parameters, draft: draft, initialSize: nil)
        case let .sendAsset(draft):
            AssetTransactionDataBuilder(params: parameters, draft: draft)
        case let .rekey(draft):
            RekeyTransactionDataBuilder(params: parameters, draft: draft)
        case let .optIn(draft):
            OptInTransactionDataBuilder(params: parameters, draft: draft)
        case let .optOut(draft):
            OptOutTransactionDataBuilder(params: parameters, draft: draft)
        }
    }
    
    private func signRequestResponse(signerAccount: Account, transactions: [[Data]], transactionController: TransactionController) async -> JointAccountSignRequestResponse {
       
        var signatures: [[String]] = []
        
        for transactionGroup in transactions {
            
            var signaturesGroup: [String] = []
            
            for transactionData in transactionGroup {
                guard let signature = await transactionController.singature(signerAccount: signerAccount, transactionData: transactionData)?.base64EncodedString() else { continue }
                signaturesGroup.append(signature)
            }
            
            signatures.append(signaturesGroup)
        }
        
        return JointAccountSignRequestResponse(
            address: signerAccount.address,
            response: .signed,
            signatures: signatures,
            deviceId: nil
        )
    }
}

extension JointAccountTransactionHandler.Metadata {
    
    var signRequestMetadata: SignRequestMetadata {
        
        let transactionResponses = apiResponse.transactionLists.flatMap(\.responses)
        let signaturesInfo = apiResponse.jointAccount.participantAddresses
            .map { address in
                let status = transactionResponses.first(where: { $0.address == address })?.response
                return SignRequestInfo(address: address, status: status)
            }
        
        return SignRequestMetadata(signRequestID: apiResponse.id, transactions: apiResponse.transactionLists, proposerAddress: proposerAddress, signaturesInfo: signaturesInfo, threshold: apiResponse.jointAccount.threshold, deadline: apiResponse.expectedExpireDatetime)
    }
}
