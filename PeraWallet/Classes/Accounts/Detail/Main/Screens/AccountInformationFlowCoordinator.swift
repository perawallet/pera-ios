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

//   AccountInformationFlowCoordinator.swift

import UIKit
import pera_wallet_core

final class AccountInformationFlowCoordinator  {
    
    private unowned let presentingScreen: BaseViewController
    private let sharedDataController: SharedDataController

    private lazy var rescanRekeyedAccountsCoordinator = RescanRekeyedAccountsCoordinator(presenter: presentingScreen)
    private lazy var transitionToAccountInformation = BottomSheetTransition(presentingViewController: presentingScreen)

    private lazy var undoRekeyFlowCoordinator = UndoRekeyFlowCoordinator(
        presentingScreen: presentingScreen,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToStandardAccountFlowCoordinator = RekeyToStandardAccountFlowCoordinator(
        presentingScreen: presentingScreen,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToLedgerAccountFlowCoordinator = RekeyToLedgerAccountFlowCoordinator(
        presentingScreen: presentingScreen,
        sharedDataController: sharedDataController
    )

    init(
        presentingScreen: BaseViewController,
        sharedDataController: SharedDataController
    ) {
        self.presentingScreen = presentingScreen
        self.sharedDataController = sharedDataController
    }
}

extension AccountInformationFlowCoordinator {
    func launch(_ sourceAccount: Account) {
        
        let authorization = sourceAccount.authorization
        
        if authorization.isStandard {
            openAccountInformationForStandardAccount(sourceAccount)
            return
        }
        
        if authorization.isJointAccount || authorization.isJointAccountRekeyed {
            openAccountInformationForJointAccount(sourceAccount)
            return
        }

        if authorization.isWatch {
            openAccountInformationForWatchAccount(sourceAccount)
            return
        }

        if authorization.isLedger {
            openAccountInformationForLedgerAccount(sourceAccount)
            return
        }

        if authorization.isNoAuth {
            openAccountInformationForNoAuthInLocal(sourceAccount)
            return
        }

        if authorization.isRekeyed,
           let authAccount = sharedDataController.authAccount(of: sourceAccount) {
            openAccountInformationForRekeyedAccount(
                sourceAccount: sourceAccount,
                authAccount: authAccount
            )
            return
        }
    }
}

extension AccountInformationFlowCoordinator {
    private func openAccountInformationForStandardAccount(_ sourceAccount: Account) {
        let screen = transitionToAccountInformation.perform(
            .standardAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        ) as? StandardAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return}

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            case .performRescanRekeyedAccounts:
                self.openRescanRekeyedAccounts(accounts: [sourceAccount])
            case .performImportConnectedAccounts:
                self.openImportConnectedAccounts(account: sourceAccount)
            }
        }
    }

    private func openAccountInformationForWatchAccount(_ sourceAccount: Account) {
        let screen = transitionToAccountInformation.perform(.watchAccountInformation(account: sourceAccount), by: .presentWithoutNavigationController) as? WatchAccountInformationScreen
        screen?.onScanButtonTap = { [weak self] in
            self?.openImportConnectedAccounts(account: sourceAccount)
        }
    }

    private func openAccountInformationForLedgerAccount(_ sourceAccount: Account) {
        let screen = transitionToAccountInformation.perform(
            .ledgerAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        ) as? LedgerAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return}

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            case .performRescanRekeyedAccounts:
                self.openRescanRekeyedAccounts(accounts: [sourceAccount])
            case .performImportConnectedAccounts:
                self.openImportConnectedAccounts(account: sourceAccount)
            }
        }
    }

    private func openAccountInformationForRekeyedAccount(
        sourceAccount: Account,
        authAccount: AccountHandle
    ) {
        let screen = transitionToAccountInformation.perform(
            .rekeyedAccountInformation(
                sourceAccount: sourceAccount,
                authAccount: authAccount.value
            ),
            by: .presentWithoutNavigationController
        ) as? RekeyedAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            case .performUndoRekey:
                self.openUndoRekey(sourceAccount)
            case .performRescanRekeyedAccounts:
                self.openRescanRekeyedAccounts(accounts: [sourceAccount])
            case .performImportConnectedAccounts:
                self.openImportConnectedAccounts(account: sourceAccount)
            }
        }
    }
    
    private func openAccountInformationForJointAccount(_ sourceAccount: Account) {
        let screen = transitionToAccountInformation.perform(
            .jointAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        ) as? JointAccountInformationScreen
        screen?.eventHandler = {
            [weak self] event in
            guard let self else { return}

            switch event {
            case .performRekeyToLedger:
                self.openRekeyToLedgerAccount(sourceAccount)
            case .performRekeyToStandard:
                self.openRekeyToStandardAccount(sourceAccount)
            case .performRescanRekeyedAccounts:
                self.openRescanRekeyedAccounts(accounts: [sourceAccount])
            case .performImportConnectedAccounts:
                self.openImportConnectedAccounts(account: sourceAccount)
            }
        }
    }

    private func openAccountInformationForNoAuthInLocal(_ sourceAccount: Account) {
        let authorization = sourceAccount.authorization

        if authorization.isRekeyedToNoAuthInLocal {
            transitionToAccountInformation.perform(
                .anyToNoAuthRekeyedAccountInformation(account: sourceAccount),
                by: .presentWithoutNavigationController
            )
            return
        }

        transitionToAccountInformation.perform(
            .noAuthAccountInformation(account: sourceAccount),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountInformationFlowCoordinator {
    private func openRekeyToStandardAccount(_ sourceAccount: Account) {
        presentingScreen.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            rekeyToStandardAccountFlowCoordinator.launch(sourceAccount)
        }
    }

    private func openRekeyToLedgerAccount(_ sourceAccount: Account) {
        presentingScreen.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            rekeyToLedgerAccountFlowCoordinator.launch(sourceAccount)
        }
    }
    
    private func openRescanRekeyedAccounts(accounts: [Account]) {
        presentingScreen.dismiss(animated: true) { [weak self] in
            self?.rescanRekeyedAccountsCoordinator.rescan(accounts: accounts, nextStep: .dismiss)
        }
    }
    
    private func openImportConnectedAccounts(account: Account) {
        presentingScreen.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            ImportAccountsHandler.handle(account: account, presenter: self.presentingScreen)
        }
    }

    private func openUndoRekey(_ sourceAccount: Account) {
        presentingScreen.dismiss(animated: true) {
            [weak self] in
            guard let self else { return }
            undoRekeyFlowCoordinator.launch(sourceAccount)
        }
    }
}
