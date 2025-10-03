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

//   SettingsListCompatibilityController.swift

import UIKit

final class SettingsListCompatibilityController: SwiftUICompatibilityBaseViewController {
    
    // MARK: - Properties
    
    private lazy var algorandSecureBackupFlowCoordinator: AlgorandSecureBackupFlowCoordinator = AlgorandSecureBackupFlowCoordinator(configuration: configuration, presentingScreen: self)
    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)
    
    // MARK: - Initialisers
    
    override init(configuration: ViewControllerConfiguration, hostingController: UIViewController) {
        super.init(configuration: configuration, hostingController: hostingController)
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    
    func moveTo(option: SettingsListView.LegacyNavigationOption) {
        switch option {
        case .back:
            navigationController?.popViewController(animated: true)
        case .security:
            open(.securitySettings, by: .push)
        case .contacts:
            open(.contacts, by: .push)
        case .notifications:
            open(.notificationFilter, by: .push)
        case .walletConnect:
            open(.walletConnectSessionList, by: .push)
        case .currency:
            open(.currencySelection, by: .push)
        case .theme:
            open(.appearanceSelection, by: .push)
        case .rateApp:
            bottomModalTransition.perform(.walletRating, by: .presentWithoutNavigationController)
        case .developer:
            open(.developerSettings, by: .push)
        }
    }
    
    func performLogoutAction() {
        
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-settings-logout".uiImage,
            title: String(localized: "settings-delete-data-title"),
            description: .plain(String(localized: "settings-logout-detail")),
            primaryActionButtonTitle: String(localized: "settings-logout-button-delete"),
            secondaryActionButtonTitle: String(localized: "title-keep"),
            primaryAction: { [weak self] in
                guard let self else { return }
                self.logout()
            }
        )
        
        bottomModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator),
            by: .presentWithoutNavigationController
        )
    }
    
    // MARK: - Logout
    
    private func logout() {
        
        guard let rootViewController = UIApplication.shared.rootViewController() else { return }

        rootViewController.deleteAllData() { [weak self] isCompleted in
            
            guard isCompleted else {
                self?.presentLogoutErrorScreen()
                return
            }
            
            self?.presentLogoutSuccessScreen()
        }
    }

    private func presentLogoutSuccessScreen() {
        
        let configurator = BottomWarningViewConfigurator(
            image: "icon-approval-check".uiImage,
            title: String(localized: "settings-logout-success-message"),
            secondaryActionButtonTitle: String(localized: "title-close")
        )

        bottomModalTransition.perform(.bottomWarning(configurator: configurator), by: .presentWithoutNavigationController)
    }
    
    private func presentLogoutErrorScreen() {
        bannerController?.presentErrorBanner(title: String(localized: "title-error"), message: String(localized: "pass-phrase-verify-sdk-error"))
    }
}
