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

//   JointAccoountTransactionRequestSummaryModel.swift

import pera_wallet_core

protocol JointAccountTransactionRequestSummaryModelable {
    
    var viewModel: JointAccountTransactionRequestSummaryViewModel { get }
    
    @MainActor func confirmTransaction()
    @MainActor func declineTransaction()
    @MainActor func requestTransactionDetails()
    func requestRawAddress()
}

final class JointAccountTransactionRequestSummaryViewModel: ObservableObject {
    
    enum Action {
        case presentTransactionDetails(account: Account, transaction: TransactionItem)
        case copyAddress(address: String)
        case success
    }
    
    enum InternalError: Error {
        case noTransaction
        case unableToDecodeMsgPack(error: NSError)
        case unableToDecodeSDKTransaction(error: Error)
        case unableToDecodeSDKTransactionFromJson
        case noTransactionReceiver
        case noFee
        case noParticipantAccount
        case unableToSignTransaction(error: Error)
    }
    
    @Published fileprivate(set) var receiverAddress: String = ""
    @Published fileprivate(set) var algoAmount: String = ""
    @Published fileprivate(set) var fiatAmount: String = ""
    @Published fileprivate(set) var transactionFee: String = ""
    @Published fileprivate(set) var action: Action?
    @Published fileprivate(set) var error: InternalError?
}

final class JointAccountTransactionRequestSummaryModel: JointAccountTransactionRequestSummaryModelable {
    
    // MARK: - Properties - JointAccountTransactionRequestSummaryModelable
    
    let viewModel = JointAccountTransactionRequestSummaryViewModel()
    
    // MARK: - Properties
    
    private let accountsService: AccountsServiceable
    private let currencyService: CurrencyServiceable
    private let signRequest: SignRequestObject
    private let transactionController: TransactionController
    
    // MARK: - Initialisers
    
    init(transactionController: TransactionController, accountsService: AccountsServiceable, currencyService: CurrencyServiceable, request: SignRequestObject) {
        self.transactionController = transactionController
        self.accountsService = accountsService
        self.currencyService = currencyService
        signRequest = request
        
        do {
            try setupData()
        } catch {
            viewModel.error = error
        }
    }
    
    // MARK: - Setups
    
    private func setupData() throws(JointAccountTransactionRequestSummaryViewModel.InternalError) {
        
        let sdkTransaction = try sdkTransaction(signRequest: signRequest)
        guard let receiverAddress = sdkTransaction.receiver else { throw .noTransactionReceiver }
        let algos = sdkTransaction.amount.toAlgos
        
        viewModel.receiverAddress = receiverAddress.shortAddressDisplay
        viewModel.algoAmount = "\(algos)"
        viewModel.fiatAmount = currencyService.formattedFiatAmount(algoAmount: algos)
        
        let algoCurrencyFormatter = CurrencyFormatter()
        algoCurrencyFormatter.currency = AlgoLocalCurrency()
        
        guard let fee = sdkTransaction.fee?.toAlgos.doubleValue else { throw .noFee }
        viewModel.transactionFee = algoCurrencyFormatter.format(-fee) ?? ""
    }
    
    // MARK: - Actions - JointAccountTransactionRequestSummaryModelable
    
    @MainActor
    func confirmTransaction() {
        performSignRequests(isConfirmed: true)
    }
    
    @MainActor
    func declineTransaction() {
        performSignRequests(isConfirmed: false)
    }
    
    @MainActor
    func requestTransactionDetails() {
        
        let account: Account
        let sdkTransaction: SDKTransaction
        
        do {
            sdkTransaction = try self.sdkTransaction(signRequest: signRequest)
            account = try participantAccount()
        } catch {
            viewModel.error = error
            return
        }
        
        let transaction = TransactionViewModel(
            amount: sdkTransaction.amount.toAlgos,
            fee: sdkTransaction.fee,
            transferType: .sent,
            id: signRequest.id,
            type: .payment,
            sender: sdkTransaction.sender,
            receiver: sdkTransaction.receiver,
            isSelfTransaction: false,
            status: .pending,
            allInnerTransactionsCount: 0,
            noteRepresentation: nil
        )
        
        viewModel.action = .presentTransactionDetails(account: account, transaction: transaction)
    }
    
    func requestRawAddress() {
        
        guard let receiverAddress = try? sdkTransaction(signRequest: signRequest).receiver else {
            viewModel.error = .noTransactionReceiver
            return
        }
        
        viewModel.action = .copyAddress(address: receiverAddress)
    }
    
    // MARK: - Actions
    
    @MainActor
    private func performSignRequests(isConfirmed: Bool) {
        participantAccounts()
            .forEach { performSignRequest(signerAccount: $0, isConfirmed: isConfirmed) }
    }
    
    private func performSignRequest(signerAccount: Account, isConfirmed: Bool) {
        
        let response: AccountsService.JointAccountSignResponse
        
        if isConfirmed {
            
            let signatures = signRequest.transactionLists
                .map { $0.rawTransactions.compactMap { Data(base64Encoded: $0) }}
                .map {
                    $0
                        .compactMap { transactionController.singature(signerAccount: signerAccount, transactionData: $0) }
                        .map { $0.base64EncodedString() }
                }
            
            response = .signed(signatures: signatures)
            
        } else {
            response = .declined
        }
        
        Task {
            do {
                try await accountsService.signJointAccountTransaction(participantAddress: signerAccount.address, signRequestId: signRequest.id, response: response)
                Task { @MainActor in
                    viewModel.action = .success
                }
            } catch {
                Task { @MainActor in
                    viewModel.error = .unableToSignTransaction(error: error)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func sdkTransaction(signRequest: SignRequestObject) throws(JointAccountTransactionRequestSummaryViewModel.InternalError) -> SDKTransaction {
        
        guard let msgpackTransaction = signRequest.transactionLists.first?.rawTransactions.first else { throw .noTransaction }
        let encodedMsgpackTransaction = Data(base64Encoded: msgpackTransaction)
        
        var error: NSError?
        let json = AlgorandSDK().msgpackToJSON(encodedMsgpackTransaction, error: &error)
        
        if let error {
            throw .unableToDecodeMsgPack(error: error)
        }
        
        guard let jsonData = json.data(using: .utf8) else { throw .unableToDecodeSDKTransactionFromJson }
        
        do {
            return try JSONDecoder().decode(SDKTransaction.self, from: jsonData)
        } catch {
            throw .unableToDecodeSDKTransaction(error: error)
        }
    }
    
    @MainActor
    private func participantAccount() throws(JointAccountTransactionRequestSummaryViewModel.InternalError) -> Account {
        
        let participants = signRequest.jointAccount.participantAddresses
        let participantAccounts = accountsService.accounts.value.filter { participants.contains($0.address) }
        
        guard let participantAddress = participantAccounts.first?.address, let account = accountsService.account(address: participantAddress) else { throw .noParticipantAccount }
        return account
    }
    
    @MainActor
    private func participantAccounts() -> [Account] {
        let participants = signRequest.jointAccount.participantAddresses
        return accountsService.accounts.value
            .filter { participants.contains($0.address) }
            .compactMap { accountsService.account(address: $0.address) }
    }
}
