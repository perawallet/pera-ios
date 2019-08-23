//
//  SettingsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsViewController: BaseViewController {
    
    private lazy var settingsView: SettingsView = {
        let settingsView = SettingsView()
        return settingsView
    }()
    
    private let viewModel = SettingsViewModel()
    
    private let localAuthenticator = LocalAuthenticator()
    
    private var authManager: AuthManager?
    
    private var isAuctionsEnabled: Bool {
        return Environment.current.isAuctionsEnabled
    }
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        authManager = AuthManager()
    }
    
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
        authManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAuctionsEnabled {
            settingsView.collectionView.reloadItems(at: [IndexPath(row: 4, section: 0)])
        }
    }
}

// MARK: UICollectionViewDataSource

extension SettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isAuctionsEnabled ? 5 : 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        switch mode {
        case .serverSettings, .password:
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
        case .language:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsInfoCell.reusableIdentifier,
                for: indexPath) as? SettingsInfoCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureInfo(cell, with: mode)
            
            return cell
        case .coinlist:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CoinlistCell.reusableIdentifier,
                for: indexPath) as? CoinlistCell else {
                    fatalError("Index path is out of bounds")
            }
            
            if let session = session {
                viewModel.configureCoinlist(cell, for: session)
            }
            
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
        
        return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        switch mode {
        case .serverSettings:
            open(.nodeSettings(mode: .initialize), by: .push)
        case .password:
            open(.choosePassword(mode: ChoosePasswordViewController.Mode.resetPassword, route: nil), by: .present)
        default:
            break
        }
    }
}

// MARK: - SettingsViewModelDelegate

extension SettingsViewController: SettingsViewModelDelegate {
    
    func settingsViewModel(_ viewModel: SettingsViewModel, didToggleValue value: Bool, atIndexPath indexPath: IndexPath) {
        
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item),
            mode == .localAuthentication else {
            return
        }
        
        guard let cell = settingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
            return
        }
        
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
    
    func settingsViewModel(_ viewModel: SettingsViewModel, didTapCoinlistActionIn cell: CoinlistCell) {
        if cell.contextView.actionMode == .connect {
            authManager?.authorize()
        } else {
            session?.coinlistToken = nil
            session?.coinlistUserId = nil
            cell.contextView.actionMode = .connect
            
            NotificationCenter.default.post(name: Notification.Name.CoinlistDisconnected, object: self)
        }
    }
}

// MARK: AuthManagerDelegate

extension SettingsViewController: AuthManagerDelegate {
    
    func authManager(_ authManager: AuthManager, didCaptureToken token: String?, withError error: Error?) {
        if error != nil {
            displaySimpleAlertWith(title: "title-error".localized, message: "auction-auth-error-message".localized)
            self.authManager = AuthManager()
            self.authManager?.delegate = self
            
            return
        }
        
        guard let code = token else {
            return
        }
        
        guard let cell = settingsView.collectionView.cellForItem(at: IndexPath(item: 4, section: 0)) as? CoinlistCell else {
            return
        }
        
        cell.contextView.actionMode = .disconnect
        
        NotificationCenter.default.post(name: Notification.Name.CoinlistConnected, object: self, userInfo: ["code": code])
        
        tabBarController?.selectedIndex = 2
    }
}

// MARK: SettingsViewDelegate

extension SettingsViewController: SettingsViewDelegate {
    func settingsViewDidTapFeedbackView(_ settingsView: SettingsView) {
        open(.feedback, by: .push)
    }
}
