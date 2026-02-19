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

//   AccountServiceMock.swift

@testable import pera_staging
@testable import pera_wallet_core
import Combine

final class AccountServiceMock: AccountsServiceable {
    
    // MARK: - Properties - AccountsServiceable
    
    var accounts: ReadOnlyPublisher<Set<PeraAccount>> { accountsPublisher.readOnlyPublisher() }
    var error: AnyPublisher<AccountsService.ServiceError, Never> { errorPublisher.eraseToAnyPublisher() }
    var network: CoreApiManager.BaseURL.Network = .testNet
    
    // MARK: - Properties
    
    var accountsPublisher = CurrentValueSubject<Set<PeraAccount>, Never>([])
    var errorPublisher = PassthroughSubject<AccountsService.ServiceError, Never>()
    
    // MARK: - Actions - AccountsServiceable
    
    func createJointAccount(participants: [String], threshold: Int, name: String) async throws(AccountsService.ActionError) {}
    func createJointAccountSignTransactionRequest(jointAccountAddress: String, proposerAddress: String, rawTransactionLists: [[String]], responses: [JointAccountSignRequestResponse]) async throws(AccountsService.ActionError) -> ProposeSignResponse { .mock }
    func signJointAccountTransaction(signRequestId: String, responses: [AccountsService.JointAccountSignResponse]) async throws(AccountsService.ActionError) {}
    func searchJointAccountSignTransaction(signRequestID: String) async throws(AccountsService.ActionError) -> JointAccountsSignRequestSearchResponse { .mock }
    func hasJointAccount(with participantAddresses: [String]) -> Bool { false }
    func localAccount(address: String) -> AccountInformation? { nil }
    func localAccount(peraAccount: PeraAccount) -> AccountInformation? { nil }
    func account(peraAccount: PeraAccount) -> Account? { nil }
    func account(address: String) -> Account? { nil }
}

// MARK: - Mocks

private extension ProposeSignResponse {
    static var mock: Self { Self(id: "", jointAccount: .mock, type: .async, transactionLists: [], expectedExpireDatetime: Date(), status: .pending) }
}

private extension MultiSigAccountObject {
    static var mock: Self { Self(address: "", participantAddresses: [], threshold: 0, version: 0, creationDatetime: Date(), deviceID: nil) }
}

private extension JointAccountsSignRequestSearchResponse {
    static var mock: Self { Self(results: [.mock]) }
}

private extension JointAccountsSignRequestSearchDataObject {
    static var mock: Self { Self(id: nil, jointAccount: nil, type: .async, transactionLists: nil, expectedExpireDatetime: nil, status: nil, creationDatetime: nil, failReasonDisplay: nil) }
}
