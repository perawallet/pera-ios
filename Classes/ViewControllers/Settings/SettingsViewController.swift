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
    
    private lazy var settingsView: SettingsView = {
        let settingsView = SettingsView()
        return settingsView
    }()
    
    private let viewModel = SettingsViewModel()
    
    private let localAuthenticator = LocalAuthenticator()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "settings-title".localized
        
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10.0)
            make.leading.trailing.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    override func linkInteractors() {
        settingsView.delegate = self
        settingsView.collectionView.delegate = self
        settingsView.collectionView.dataSource = self
        viewModel.delegate = self
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationEnterForeground),
            name: Notification.Name.ApplicationWillEnterForeground,
            object: nil
        )
    }
    
    @objc
    private func didApplicationEnterForeground() {
        settingsView.collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension SettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        switch mode {
        case .password:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
                for: indexPath) as? SettingsDetailCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureDetail(cell, with: mode)
            
            return cell
            
        case .localAuthentication:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ToggleCell.reusableIdentifier,
                for: indexPath) as? ToggleCell else {
                    fatalError("Index path is out of bounds")
            }
            
            let localAuthenticationStatus = localAuthenticator.localAuthenticationStatus == .allowed
            
            viewModel.configureToggle(cell, enabled: localAuthenticationStatus, with: mode, for: indexPath)
            
            return cell
        case .notifications:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ToggleCell.reusableIdentifier,
                for: indexPath) as? ToggleCell else {
                    fatalError("Index path is out of bounds")
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        self.viewModel.configureToggle(cell, enabled: true, with: mode, for: indexPath)
                    } else {
                        self.viewModel.configureToggle(cell, enabled: false, with: mode, for: indexPath)
                    }
                }
            }
            
            return cell
        case .rewards:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ToggleCell.reusableIdentifier,
                for: indexPath) as? ToggleCell else {
                    fatalError("Index path is out of bounds")
            }
            
            let rewardDisplayPreference = session?.rewardDisplayPreference == .allowed
            viewModel.configureToggle(cell, enabled: rewardDisplayPreference, with: mode, for: indexPath)
            return cell
        case .language:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsInfoCell.reusableIdentifier,
                for: indexPath) as? SettingsInfoCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureInfo(cell, with: mode)
            
            return cell
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 80.0 * verticalScale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        switch mode {
        case .password:
            open(
                .choosePassword(
                    mode: ChoosePasswordViewController.Mode.resetPassword, route: nil),
                    by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            )
        default:
            break
        }
    }
}

// MARK: - SettingsViewModelDelegate

extension SettingsViewController: SettingsViewModelDelegate {
    
    func settingsViewModel(_ viewModel: SettingsViewModel, didToggleValue value: Bool, atIndexPath indexPath: IndexPath) {
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item),
            let cell = settingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
            return
        }
        
        switch mode {
        case .localAuthentication:
            if !value {
                localAuthenticator.localAuthenticationStatus = .notAllowed
                return
            }
            
            if localAuthenticator.isLocalAuthenticationAvailable {
                localAuthenticator.authenticate { error in
                    guard error == nil else {
                        cell.contextView.toggle.setOn(false, animated: true)
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
        
        let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel) { _ in
            let indexPath = IndexPath(item: 2, section: 0)
            guard let cell = self.settingsView.collectionView.cellForItem(at: indexPath) as? ToggleCell else {
                return
            }
            
            cell.contextView.toggle.setOn(!cell.contextView.toggle.isOn, animated: true)
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
        
        let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: SettingsViewDelegate

extension SettingsViewController: SettingsViewDelegate {
    func settingsViewDidTapFeedbackView(_ settingsView: SettingsView) {
        open(.feedback, by: .push)
    }
}
