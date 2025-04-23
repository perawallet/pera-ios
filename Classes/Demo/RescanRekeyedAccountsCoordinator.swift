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

//   RescanRekeyedAccountsCoordinator.swift

import MagpieCore

final class RescanRekeyedAccountsCoordinator {
    
    enum CoordinatorError {
        case noAccount
        case apiError(_ error: APIError)
    }
    
    // MARK: - Properties
    
    private weak var presenter: BaseViewController?
    private weak var account: Account?
    
    // MARK: - Initialisers
    
    init(presenter: BaseViewController, account: Account) {
        self.presenter = presenter
        self.account = account
    }
    
    // MARK: - Actions
    
    func rescan() {
        
        guard let account else {
            handle(error: .noAccount)
            return
        }
        
        presenter?.loadingController?.startLoadingWithMessage(String(localized: "rekeyed-account-selection-list-loading"))
        
        presenter?.api?.fetchRekeyedAccounts(account.address) { [weak self] response in
            switch response {
            case let .success(rekeyedAccountsResponse):
                self?.handle(rekeyedAccountsResponse: rekeyedAccountsResponse, account: account)
            case let .failure(error, _):
                self?.handle(error: .apiError(error))
            }
        }
    }
    
    private func openAccountsSelectionList(authAccount: Account, rekeyedAccounts: [Account]) {
        presenter?.open(
            .rescanRekeyedAccountsSelectList(authAccount: authAccount, rekeyedAccounts: rekeyedAccounts),
            by: .push
        )
    }
    
    // MARK: - Handlers
    
    private func handle(rekeyedAccountsResponse: RekeyedAccountsResponse, account: Account) {
        
        presenter?.loadingController?.stopLoading()
        
        let rekeyedAccounts = rekeyedAccountsResponse.accounts
            .filter { !$0.isRekeyedToSelf }
            .map {
                $0.authorization = account.authorization.isLedger ? .unknownToLedgerRekeyed : .unknownToStandardRekeyed
                return $0
            }
        
        openAccountsSelectionList(authAccount: account, rekeyedAccounts: rekeyedAccounts)
    }
    
    private func handle(error: CoordinatorError) {
        
        presenter?.loadingController?.stopLoading()
        
        switch error {
        case .noAccount:
            presenter?.configuration.bannerController?.presentErrorBanner(title: String(localized: "default-error-message"), message: "")
        case .apiError:
            presenter?.configuration.bannerController?.presentErrorBanner(title: String(localized: "title-failed-to-fetch-rekeyed-accounts"), message: "")
        }
    }
}
