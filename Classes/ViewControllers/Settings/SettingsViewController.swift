//
//  SettingsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD
import UserNotifications

class SettingsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 402.0))
    )
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api)
    }()
    
    private lazy var settings: [[GeneralSettings]] = [developerSettings, securitySettings, preferenceSettings, appSettings]
    private lazy var developerSettings: [GeneralSettings] = [.developer]
    private lazy var securitySettings: [GeneralSettings] = [.password, .localAuthentication]
    private lazy var preferenceSettings: [GeneralSettings] = [.notifications, .rewards, .language, .currency]
    private lazy var appSettings: [GeneralSettings] = [.feedback, .termsAndServices]
    
    private lazy var settingsView = SettingsView()
    
    private let localAuthenticator = LocalAuthenticator()
    
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
        
        settingsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.safeEqualToTop(of: self)
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] {
            switch setting {
            case .developer:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .password:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .localAuthentication:
                let localAuthenticationStatus = localAuthenticator.localAuthenticationStatus == .allowed
                return setSettingsToggleCell(from: setting, isOn: localAuthenticationStatus, in: collectionView, at: indexPath)
            case .notifications:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SettingsToggleCell.reusableIdentifier,
                    for: indexPath) as? SettingsToggleCell else {
                        fatalError("Index path is out of bounds")
                }
                
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        SettingsToggleViewModel(setting: setting, isOn: settings.authorizationStatus == .authorized).configure(cell)
                    }
                }
                
                return cell
            case .rewards:
                let rewardDisplayPreference = session?.rewardDisplayPreference == .allowed
                return setSettingsToggleCell(from: setting, isOn: rewardDisplayPreference, in: collectionView, at: indexPath)
            case .language:
                return setSettingsInfoCell(from: setting, info: "settings-language-english".localized, in: collectionView, at: indexPath)
            case .currency:
                return setSettingsInfoCell(from: setting, info: "settings-currency-usd".localized, in: collectionView, at: indexPath)
            case .feedback:
                return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
            case .termsAndServices:
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
            SettingsDetailViewModel(setting: setting).configure(cell)
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    private func setSettingsInfoCell(
        from setting: Settings,
        info: String?,
        in collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> SettingsInfoCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsInfoCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsInfoCell {
            SettingsInfoViewModel(setting: setting, info: info).configure(cell)
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
            SettingsToggleViewModel(setting: setting, isOn: isOn).configure(cell)
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionFooter {
            fatalError("Unexpected element kind")
        }
        
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SettingsFooterSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? SettingsFooterSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        footerView.delegate = self
        return footerView
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72.0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if section == settings.count - 1 {
            return CGSize(width: UIScreen.main.bounds.width, height: 128.0)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let settings = settings[safe: indexPath.section],
            let setting = settings[safe: indexPath.item] {
        
            switch setting {
            case .developer:
                open(.developerSettings, by: .push)
            case .password:
                open(
                    .choosePassword(
                        mode: ChoosePasswordViewController.Mode.resetPassword, flow: nil, route: nil),
                        by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
                )
            case .feedback:
                open(.feedback, by: .push)
            case .termsAndServices:
                guard let url = URL(string: Environment.current.termsAndServicesUrl) else {
                    return
                }
                
                open(url)
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
        case .localAuthentication:
            if !value {
                localAuthenticator.localAuthenticationStatus = .notAllowed
                return
            }
            
            if localAuthenticator.isLocalAuthenticationAvailable {
                localAuthenticator.authenticate { error in
                    guard error == nil else {
                        settingsToggleCell.contextView.setToggleOn(false, animated: true)
                        return
                    }
                    
                    self.localAuthenticator.localAuthenticationStatus = .allowed
                }
                return
            }
            
            presentDisabledLocalAuthenticationAlert()
        case .notifications:
            presentNotificationAlert(isEnabled: value)
        case .rewards:
            session?.rewardDisplayPreference = value ? .allowed : .disabled
        default:
            return
        }
    }
    
    private func presentNotificationAlert(isEnabled: Bool) {
        let alertMessage: String = isEnabled ?
            "settings-notification-disabled-go-settings-text".localized :
            "settings-notification-enabled-go-settings-text".localized
        
        let alertController = UIAlertController(
            title: "settings-notification-go-settings-title".localized,
            message: alertMessage,
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel) { _ in
            let indexPath = IndexPath(item: 0, section: 2)
            guard let cell = self.settingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                return
            }
            
            cell.contextView.setToggleOn(!cell.contextView.isToggleOn, animated: true)
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: "local-authentication-go-settings-title".localized,
            message: "local-authentication-go-settings-text".localized,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel) { _ in
            let indexPath = IndexPath(item: 1, section: 1)
            guard let cell = self.settingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                return
            }
            
            cell.contextView.setToggleOn(!cell.contextView.isToggleOn, animated: true)
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentLogoutAlert() {
        let configurator = BottomInformationBundle(
            title: "settings-logout-title".localized,
            image: img("icon-settings-logout"),
            explanation: "settings-logout-detail".localized,
            actionTitle: "node-settings-action-delete-title".localized,
            actionImage: img("bg-button-red")
        ) {
            self.logout()
        }
        
        open(
            .bottomInformation(mode: .action, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
    
    private func logout() {
        session?.reset(isContactIncluded: true)
        NotificationCenter.default.post(name: .ContactDeletion, object: self, userInfo: nil)
        pushNotificationController.revokeDevice()
        open(.introduction, by: .launch, animated: false)
     }
}
