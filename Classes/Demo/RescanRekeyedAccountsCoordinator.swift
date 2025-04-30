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

//   RescanRekeyedAccountsCoordinator.swift

import MagpieCore

final class RescanRekeyedAccountsCoordinator {
    
    enum CoordinatorError: Error {
        case apiError(_ error: APIError)
        case unexpected(any Error)
    }
    
    // MARK: - Properties
    
    private weak var presenter: BaseViewController?
    
    // MARK: - Initialisers
    
    init(presenter: BaseViewController) {
        self.presenter = presenter
    }
    
    // MARK: - Actions
    
    func rescan(accounts: [Account], nextStep: RecoveredAccountsListView.NextStep) {
        
        presenter?.loadingController?.startLoadingWithMessage(String(localized: "rekeyed-account-selection-list-loading"))
        
        Task {
            do {
                let result = try await withThrowingTaskGroup(of: [RecoveredAccountsListModel.InputData].self) { taskGroup in
                    
                    accounts.forEach { account in
                        taskGroup.addTask { try await self.fetchRekeyedAccounts(account: account) }
                    }
                    
                    return try await taskGroup.reduce(into: [RecoveredAccountsListModel.InputData]()) { $0 += $1 }
                }
                
                await handle(data: result, nextStep: nextStep)
                
            } catch let error as CoordinatorError { // FIXME: Please remove this workaround when typed throws will be added to the `withCheckedThrowingContinuation` and `withThrowingTaskGroup`.
                await handle(error: error)
            } catch {
                await handle(error: .unexpected(error))
            }
        }
    }
    
    @MainActor
    private func fetchRekeyedAccounts(account: Account) async throws -> [RecoveredAccountsListModel.InputData] {
        try await withCheckedThrowingContinuation { continuation in
            
            presenter?.api?.fetchRekeyedAccounts(account.address) { [weak self] response in
                
                guard let self else { return }
                
                switch response {
                case let .success(rekeyedAccountsResponse):
                    let dataModels = rekeyedAccounts(rekeyedAccountsResponse: rekeyedAccountsResponse, account: account)
                        .map { RecoveredAccountsListModel.InputData(authAccount: account, rekeyedAccount: $0) }
                    continuation.resume(returning: dataModels)
                case let .failure(error, _):
                    continuation.resume(throwing: CoordinatorError.apiError(error))
                }
            }
        }
    }
    
    private func openAccountsSelectionList(data: [RecoveredAccountsListModel.InputData], nextStep: RecoveredAccountsListView.NextStep) {
        presenter?.open(
            .rescanRekeyedAccountsSelectList(inputData: data, nextStep: nextStep),
            by: .push
        )
    }
    
    // MARK: - Handlers
    
    private func handle(data: [RecoveredAccountsListModel.InputData], nextStep: RecoveredAccountsListView.NextStep) async {
        await MainActor.run {
            presenter?.loadingController?.stopLoading()
            openAccountsSelectionList(data: data, nextStep: nextStep)
        }
    }
    
    private func handle(error: CoordinatorError) async {
        
        await MainActor.run {
            
            presenter?.loadingController?.stopLoading()
            
            switch error {
            case .apiError:
                presenter?.configuration.bannerController?.presentErrorBanner(title: String(localized: "title-failed-to-fetch-rekeyed-accounts"), message: "")
            case .unexpected:
                presenter?.configuration.bannerController?.presentErrorBanner(title: String(localized: "default-error-message"), message: "")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func rekeyedAccounts(rekeyedAccountsResponse: RekeyedAccountsResponse, account: Account) -> [Account] {
        rekeyedAccountsResponse.accounts
            .filter { !$0.isRekeyedToSelf }
            .map {
                $0.authorization = account.authorization.isLedger ? .unknownToLedgerRekeyed : .unknownToStandardRekeyed
                return $0
            }
    }
}
