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

//   RecoveredAccountsListViewController.swift

import SwiftUI

final class RecoveredAccountsListViewController: UIHostingController<RecoveredAccountsListView> {
    
    // MARK: - Initialisers
    
    init(model: RecoveredAccountsListModel, nextStep: RecoveredAccountsListView.NextStep) {
        super.init(rootView: RecoveredAccountsListView(model: model, nextStep: nextStep))
        rootView.dismiss = { [weak self] in self?.dismiss(isSuccess: $0) }
        rootView.openDetails = { [weak self] in self?.openAccountDetails(account: $0, authAccount: $1) }
        rootView.openAddAccountTutorial = { [weak self] in self?.openAddAccountTutorial(isMultipleAccounts: $0) }
        rootView.fininshRecoveringAccounts = { [weak self] in self?.fininshRecoveringAccounts() }
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    private func dismiss(isSuccess: Bool) {
        if isSuccess {
            navigationController?.popToRootViewController(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func openAccountDetails(account: Account, authAccount: Account) {
        open(.ledgerAccountDetail(account: account, authAccount: authAccount, ledgerIndex: nil, rekeyedAccounts: nil), by: .present)
    }
    
    private func openAddAccountTutorial(isMultipleAccounts: Bool) {
        open(.tutorial(flow: .none, tutorial: .accountVerified(flow: .none, address: nil, isMultipleAccounts: isMultipleAccounts)), by: .push)
    }
    
    private func fininshRecoveringAccounts() {
        PeraUserDefaults.shouldShowNewAccountAnimation = true
        launchMain()

    }
}
