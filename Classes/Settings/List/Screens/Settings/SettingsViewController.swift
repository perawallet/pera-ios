// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  SettingsViewController.swift

import UIKit

final class SettingsViewController: BaseViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api, bannerController: bannerController)
    }()
    
    private lazy var theme = Theme()
    private lazy var settingsView = SettingsView()
    
    private lazy var dataSource = SettingsDataSource(session: session)
        
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func linkInteractors() {
        dataSource.delegate = self
        settingsView.collectionView.delegate = self
        settingsView.collectionView.dataSource = dataSource
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationEnterForeground),
            name: .ApplicationWillEnterForeground,
            object: nil
        )
    }
    
    override func prepareLayout() {
        addSettingsView()
    }
}

extension SettingsViewController {
    @objc
    private func didApplicationEnterForeground() {
        settingsView.collectionView.reloadData()
    }
}

extension SettingsViewController {
    private func addSettingsView() {
        view.addSubview(settingsView)
        
        settingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(theme.headerSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if section == dataSource.sections.count - 1 {
            return CGSize(theme.footerSize)
        }
        return .zero
    }
}

extension SettingsViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let section = dataSource.sections[safe: indexPath.section] {
            switch section {
            case .account:
                if let setting = dataSource.accountSettings[safe: indexPath.item] {
                    didSelectItemFromAccountSettings(setting)
                }
            case .appPreferences:
                if let setting = dataSource.appPreferenceSettings[safe: indexPath.item] {
                    didSelectItemFromAppPreferenceSettings(setting)
                }
            case .support:
                if let setting = dataSource.supportSettings[safe: indexPath.item] {
                    didSelectItemFromSupportSettings(setting)
                }
            }
        }
    }
    
    func didSelectItemFromAccountSettings(_ setting: AccountSettings) {
        switch setting {
        case .notifications:
            open(.notificationFilter(flow: .settings), by: .push)
        case .walletConnect:
            open(.walletConnectSessionsList, by: .push)
        default:
            break
        }
    }
    
    func didSelectItemFromAppPreferenceSettings(_ setting: AppPreferenceSettings) {
        switch setting {
        case .language:
            displayProceedAlertWith(
                title: "settings-language-change-title".localized,
                message: "settings-language-change-detail".localized
            ) { _ in
                UIApplication.shared.openAppSettings()
            }
        case .currency:
            open(.currencySelection, by: .push)
        case .appearance:
            open(.appearanceSelection, by: .push)
        default:
            break
        }
    }
    
    func didSelectItemFromSupportSettings(_ setting: SupportSettings) {
        switch setting {
        case .feedback:
            if let url = AlgorandWeb.support.link {
                open(url)
            }
        case .appReview:
            bottomModalTransition.perform(.walletRating)
        case .termsAndServices:
            guard let url = AlgorandWeb.termsAndServices.link else {
                return
            }
            
            open(url)
        case .privacyPolicy:
            guard let url = AlgorandWeb.privacyPolicy.link else {
                return
            }
            
            open(url)
        case .developer:
            open(.developerSettings, by: .push)
        }
    }
}

extension SettingsViewController: SettingsDataSourceDelegate {
    func settingsDataSource(
        _ settingsDataSource: SettingsDataSource,
        _ settingsToggleCell: SettingsToggleCell,
        didChangeValue value: Bool
    ) {
        guard let indexPath = settingsView.collectionView.indexPath(for: settingsToggleCell),
              let section = dataSource.sections[safe: indexPath.section] else {
            return
        }
        
        if section == .appPreferences,
           let setting = dataSource.appPreferenceSettings[safe: indexPath.item] {
            switch setting {
            case .rewards:
                session?.rewardDisplayPreference = value ? .allowed : .disabled
            default:
                return
            }
        }
    }
    
    func settingsDataSourceDidTapLogout(
        _ settingsDataSource: SettingsDataSource,
        _ settingsFooterSupplementaryView: SettingsFooterSupplementaryView
    ) {
        presentLogoutAlert()
    }
    
    private func presentLogoutAlert() {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-settings-logout".uiImage,
            title: "settings-logout-title".localized,
            description: "settings-logout-detail".localized,
            primaryActionButtonTitle: "node-settings-action-delete-title".localized,
            secondaryActionButtonTitle: "title-cancel".localized,
            primaryAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logout()
            }
        )

        bottomModalTransition.perform(
            .bottomWarning(configurator: bottomWarningViewConfigurator)
        )
    }
    
    private func logout() {
        session?.reset(isContactIncluded: true)
        walletConnector.resetAllSessions()
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
        open(.welcome(flow: .initializeAccount(mode: .none)), by: .launch, animated: false)
     }
}
