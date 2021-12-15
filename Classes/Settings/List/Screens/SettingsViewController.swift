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
    
    private lazy var sections: [GeneralSettings.Sections] = [.account, .appPreferences, .support]
    private lazy var settings: [[GeneralSettings.Items]] = [accountSettings, appSettings, supportSettings]
    private lazy var accountSettings: [GeneralSettings.Items] = [.backup, .security, .notifications, .walletConnect]
    private lazy var appSettings: [GeneralSettings.Items] = {
        var settings: [GeneralSettings.Items] = [.rewards, .language, .currency]
        if #available(iOS 13.0, *) {
            settings.append(.appearance)
        }
        return settings
    }()
    private lazy var supportSettings: [GeneralSettings.Items] = [.feedback, .appReview, .termsAndServices, .privacyPolicy, .developer]
    
    private lazy var settingsView = SettingsView()
        
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func linkInteractors() {
        settingsView.collectionView.delegate = self
        settingsView.collectionView.dataSource = self
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
        setupSettingsViewLayout()
    }
}

extension SettingsViewController {
    @objc
    private func didApplicationEnterForeground() {
        settingsView.collectionView.reloadData()
    }
}

extension SettingsViewController {
    private func setupSettingsViewLayout() {
        view.addSubview(settingsView)
        
        settingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let settings = settings[safe: indexPath.section],
           let setting = settings[safe: indexPath.item] {
            switch setting {
            case .rewards:
                let rewardDisplayPreference = session?.rewardDisplayPreference == .allowed
                return setSettingsToggleCell(from: setting, isOn: rewardDisplayPreference, in: collectionView, at: indexPath)
            case .walletConnect:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .notifications:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .language:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .currency:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .appearance:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .feedback:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .appReview:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .termsAndServices:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .privacyPolicy:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .developer:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .backup:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .security:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            }
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func setSettingsDetailCell(
        from setting: Settings,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsDetailCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsDetailCell {
            cell.bindData(SettingsDetailViewModel(setting: setting))
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func setSettingsToggleCell(
        from setting: Settings,
        isOn: Bool,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsToggleCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsToggleCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsToggleCell {
            cell.delegate = self
            cell.bindData(SettingsToggleViewModel(setting: setting, isOn: isOn))
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SettingsFooterSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? SettingsFooterSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            footerView.delegate = self
            return footerView
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SettingsHeaderSuplementaryView.reusableIdentifier,
                for: indexPath
            ) as? SettingsHeaderSuplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            headerView.bindData(SettingsHeaderViewModel(name: sections[indexPath.section]))
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: theme.cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: theme.headerHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if section == settings.count - 1 {
            return CGSize(width: UIScreen.main.bounds.width, height: theme.footerHeight)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] {
        
            switch setting {
            case .feedback:
                if let url = AlgorandWeb.support.link {
                    open(url)
                }
            case .walletConnect:
                open(.walletConnectSessions, by: .push)
            case .notifications:
                open(.notificationFilter(flow: .settings), by: .push)
            case .appReview:
                AlgorandAppStoreReviewer().requestManualReview(forAppWith: Environment.current.appID)
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
            default:
                break
            }
        }
    }
}

extension SettingsViewController: SettingsFooterSupplementaryViewDelegate {
    func settingsFooterSupplementaryViewDidTapLogoutButton(_ settingsFooterSupplementaryView: SettingsFooterSupplementaryView) {
        presentLogoutAlert()
    }
}

extension SettingsViewController: SettingsToggleCellDelegate {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool) {
        guard let indexPath = settingsView.collectionView.indexPath(for: settingsToggleCell),
            let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] else {
            return
        }
        
        switch setting {
        case .rewards:
            session?.rewardDisplayPreference = value ? .allowed : .disabled
        default:
            return
        }
    }
    
    private func presentLogoutAlert() {
        let bottomWarningViewConfigurator = BottomWarningViewConfigurator(
            image: "icon-settings-logout".uiImage,
            title: "settings-logout-title".localized,
            description: "settings-logout-detail".localized,
            primaryActionButtonTitle: "node-settings-action-delete-title".localized,
            secondaryActionButtonTitle: "title-cancel".localized
        ) { [weak self] in
            guard let self = self else {
                return
            }
            self.logout()
        }

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
