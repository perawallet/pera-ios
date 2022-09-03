// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AccountExportFlowCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class AccountExporterFlowCoordinator {
    private unowned let presentingScreen: UIViewController
    private let qrExportInformation: QRExportInformations
    private let api: ALGAPI
    private var accounts: [Account] = []
    private var session: Session?
    private var confirmDomainScreen: UIViewController?

    init(
        presentingScreen: UIViewController,
        qrExportInformations: QRExportInformations,
        api: ALGAPI,
        session: Session?
    ) {
        self.presentingScreen = presentingScreen
        self.qrExportInformation = qrExportInformations
        self.api = api
        self.session = session
    }
}

extension AccountExporterFlowCoordinator {
    func launch() {
        navigateToAccountSelection()
    }

    private func navigateToAccountSelection() {
        let screen = Screen.exportAccountList {
            [weak self] event, exportAccountListScreen in

            guard let self = self else {
                return
            }

            switch event {
            case .performContinue(let accounts):
                self.accounts = accounts

                self.navigateToConfirmDomain(on: exportAccountListScreen)
            }
        }

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func navigateToConfirmDomain(on viewController: UIViewController) {
        let screen = Screen.exportAccountsDomainConfirmation {
            [weak self] event, domainConfirmationScreen in
            guard let self = self else {
                return
            }

            switch event {
            case .performContinue:
                self.navigateToPasswordScreenIfNeeded(on: domainConfirmationScreen)
            }
        }

        viewController.open(
            screen,
            by: .push
        )
    }

    private func navigateToPasswordScreenIfNeeded(on viewController: UIViewController) {
        guard let session = self.session else {
            return
        }

        confirmDomainScreen = viewController

        if !session.hasPassword() {
            navigateToConfirmSelection(on: viewController)
            return
        }

        navigateToPasswordScreen(on: viewController)
    }

    private func navigateToPasswordScreen(on viewController: UIViewController) {
        let localAuthenticator = LocalAuthenticator()

        if localAuthenticator.localAuthenticationStatus != .allowed {
            let controller = viewController.open(
                .choosePassword(
                    mode: .confirm(flow: .viewPassphrase),
                    flow: nil
                ),
                by: .push
            ) as? ChoosePasswordViewController
            controller?.isModalInPresentation = true
            controller?.delegate = self
            return
        }

        localAuthenticator.authenticate {
            [weak self] error in

            guard let self = self,
                  error == nil else {
                return
            }

            self.navigateToConfirmSelection(on: viewController)
        }
    }

    private func navigateToConfirmSelection(on viewController: UIViewController) {
        let accounts = self.accounts

        let screen = Screen.exportAccountsConfirmationList(selectedAccounts: accounts) {
            [weak self] event, confirmationListScreen in
            guard let self = self else {
                return
            }

            switch event {
            case .performCancel:
                confirmationListScreen.dismissScreen()
            case .performContinue(let confirmedAccounts):
                self.exportAccounts(on: confirmationListScreen, didSelectAccounts: confirmedAccounts)
            }
        }

        viewController.open(
            screen,
            by: .push
        )
    }
}

extension AccountExporterFlowCoordinator: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        guard let viewController = confirmDomainScreen, isConfirmed else {
            return
        }

        choosePasswordViewController.popScreen()

        navigateToConfirmSelection(on: viewController)
    }
}

extension AccountExporterFlowCoordinator {
    private func exportAccounts(
        on screen: ExportAccountsConfirmationListScreen,
        didSelectAccounts accounts: [Account]
    ) {
        screen.startLoading()

        guard let deviceId = session?.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }

        let exportAccountDraft = ExportAccountDraft(deviceId: deviceId)
        exportAccountDraft.populate(accounts: accounts, with: session)

        let encryptedAccountDraft = EncryptedExportAccountDraft(
            draft: exportAccountDraft,
            qrExportInformations: qrExportInformation
        )
        api.exportAccounts(encryptedAccountDraft) { [weak self] response in
            guard let self = self else {
                return
            }

            screen.stopLoading()

            switch response {
            case .success:
                self.navigateToSuccessScreen(on: screen)
            case .failure(let apiError):
                screen.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: apiError.description
                )
            }
        }
    }

    private func navigateToSuccessScreen(on viewController: UIViewController) {
        let screen = Screen.exportAccountsResult { event, screen in
            switch event {
            case .performClose:
                screen.dismissScreen()
            }
        }

        viewController.open(
            screen,
            by: .push
        )
    }
}
