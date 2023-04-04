// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupImportFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class AlgorandSecureBackupImportFlowCoordinator {
    private lazy var pushNotificationController = PushNotificationController(
        target: ALGAppTarget.current,
        session: configuration.session!,
        api: configuration.api!,
        bannerController: configuration.bannerController
    )

    private let configuration: ViewControllerConfiguration
    private let algorandSDK = AlgorandSDK()
    private unowned let presentingScreen: UIViewController

    init(configuration: ViewControllerConfiguration, presentingScreen: UIViewController) {
        self.configuration = configuration
        self.presentingScreen = presentingScreen
    }
}

extension AlgorandSecureBackupImportFlowCoordinator {
    func launch() {
        openImportBackup()
    }

    private func openImportBackup() {
        let screen: Screen = .algorandSecureBackupImportBackup { [weak self] event, screen in
            guard let self else { return }
            switch event {
            case .backupSelected(let file):
                self.openImportMnemonic(with: file, from: screen)
            }
        }
        presentingScreen.open(screen, by: .push)
    }
}

extension AlgorandSecureBackupImportFlowCoordinator {
    private func openImportMnemonic(with backup: SecureBackup, from viewController: UIViewController) {
        let screen: Screen = .algorandSecureBackupRecoverMnemonic(backup: backup) { [weak self] event, screen in
            guard let self else { return }

            switch event {
            case .decryptedBackup(let backupParameters):
                self.openRestoreAccountListScreen(with: backupParameters.accounts, from: screen)
            }
        }

        viewController.open(screen, by: .push)
    }

    private func openSuccessScreen(
        with result: ImportAccountScreen.Result,
        from viewController: UIViewController
    ) {
        let screen: Screen = .algorandSecureBackupImportSuccess(result: result) { event, screen in
            switch event {
            case .didGoToHome:
                screen.dismissScreen()
            }
        }

        viewController.open(screen, by: .push)
    }

    private func openRestoreAccountListScreen(
        with importedAccounts: [AccountImportParameters],
        from viewController: UIViewController
    ) {
        var accountsDictionary: [String: AccountImportParameters] = [:]

        importedAccounts.forEach { accountParameter in
            accountsDictionary[accountParameter.address] = accountParameter
        }

        let accounts = importedAccounts.map { accountParameter in
            let accountAddress = accountParameter.address

            let accountInformation = AccountInformation(
                address: accountAddress,
                name: accountParameter.name ?? accountAddress.shortAddressDisplay,
                type: accountParameter.accountType.rawAccountType
            )

            return Account(localAccount: accountInformation)
        }

        let screen: Screen = .algorandSecureBackupRestoreAccountList(accounts: accounts) { event, screen in
            switch event {
            case .performContinue(let accounts):
                let filteredAccounts = accounts.compactMap { account in
                    return accountsDictionary[account.address]
                }
                let transferAccounts = self.convertAccountParametersToTransferAccounts(from: filteredAccounts)
                let importConfiguration = self.saveTransferAccounts(
                    from: importedAccounts,
                    transferAccounts: transferAccounts
                )
                self.openSuccessScreen(with: importConfiguration, from: screen)
            }
        }

        viewController.open(screen, by: .push)
    }

    private func convertAccountParametersToTransferAccounts(
        from accountParameters: [AccountImportParameters]
    ) -> [TransferAccount] {
        var currentPreferredOrder = configuration.sharedDataController.getPreferredOrderForNewAccount()
        var transferAccounts: [TransferAccount] = []
        let algorandSDK = AlgorandSDK()

        for accountParameter in accountParameters where accountParameter.isImportable(using: algorandSDK) {
            guard let privateKey = accountParameter.privateKey else {
                continue
            }

            let accountAddress = accountParameter.address

            let accountInformation = AccountInformation(
                address: accountAddress,
                name: accountParameter.name ?? accountAddress.shortAddressDisplay,
                type: accountParameter.accountType.rawAccountType,
                preferredOrder: currentPreferredOrder
            )
            transferAccounts.append(
                TransferAccount(
                    privateKey: privateKey,
                    accountInformation: accountInformation
                )
            )
            currentPreferredOrder = currentPreferredOrder.advanced(by: 1)
        }

        return transferAccounts
    }

    private func saveTransferAccounts(
        from accountParameters: [AccountImportParameters],
        transferAccounts: [TransferAccount]
    ) -> ImportAccountScreen.Result {
        let session = configuration.session
        let sharedDataController = configuration.sharedDataController

        guard let session, !transferAccounts.isEmpty else {
            return ImportAccountScreen.Result(
                importedAccounts: [],
                unimportedAccounts: [],
                parameters: accountParameters
            )
        }

        var importableAccounts: [AccountInformation] = []
        var unimportedAccounts: [AccountInformation] = []

        for transferAccount in transferAccounts {
            let accountAddress = transferAccount.accountInformation.address

            if sharedDataController.accountCollection[accountAddress] != nil {
                unimportedAccounts.append(transferAccount.accountInformation)
            } else {
                session.savePrivate(transferAccount.privateKey, for: accountAddress)
                importableAccounts.append(transferAccount.accountInformation)
            }
        }

        saveAccounts(importableAccounts)

        return ImportAccountScreen.Result(
            importedAccounts: importableAccounts.map { .init(localAccount: $0) },
            unimportedAccounts: unimportedAccounts.map { .init(localAccount: $0) },
            parameters: accountParameters
        )
    }

    private func saveAccounts(_ accounts: [AccountInformation]) {
        guard let session = configuration.session, !accounts.isEmpty else {
            return
        }

        let authenticatedUser = session.authenticatedUser ?? User()
        authenticatedUser.addAccounts(accounts)

        pushNotificationController.sendDeviceDetails()

        NotificationCenter.default.post(
            name: .didAddAccount,
            object: self
        )

        session.authenticatedUser = authenticatedUser
    }
}

