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

//   SecretDeveloperMenuViewController.swift

import UIKit
import pera_wallet_core

final class SecretDeveloperMenuViewController: BaseViewController {
    
    private lazy var theme = Theme()
    private lazy var securitySettingsView = SecuritySettingsView()
    
    private var settings: [[SecretDeveloperSettings]] = [[.enableTestCards]]
    
    private lazy var localAuthenticator = LocalAuthenticator(session: session!)
    
    private var enableTestCards: Bool {
        get { PeraUserDefaults.enableTestCards ?? false }
        set { PeraUserDefaults.enableTestCards = newValue }
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = String(localized: "settings-secret-dev-menu")
    }

    override func linkInteractors() {
        securitySettingsView.collectionView.delegate = self
        securitySettingsView.collectionView.dataSource = self
    }
    
    override func prepareLayout() {
        addSecuritySettingsView()
    }
}

extension SecretDeveloperMenuViewController {
    private func addSecuritySettingsView() {
        view.addSubview(securitySettingsView)
        
        securitySettingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SecretDeveloperMenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

extension SecretDeveloperMenuViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = settings[safe: indexPath.section], let setting = section[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        switch setting {
        case .enableTestCards:
            let cell = collectionView.dequeue(SettingsToggleCell.self, at: indexPath)
            cell.delegate = self
            cell.bindData(SettingsToggleViewModel(setting: setting, isOn: enableTestCards))
            return cell
        }
    }
}

extension SecretDeveloperMenuViewController: SettingsToggleCellDelegate {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool) {
        guard let indexPath = securitySettingsView.collectionView.indexPath(for: settingsToggleCell),
            let section = settings[safe: indexPath.section],
            let setting = section[safe: indexPath.item] else {
            return
        }
        
        switch setting {
        case .enableTestCards:
            enableTestCards = value
        }
    }
}

extension SecretDeveloperMenuViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.popScreen()

        let indexPath = IndexPath(item: 1, section: 1)
        guard let cell =
                securitySettingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                    return
                }

        if isConfirmed {
            do {
                try localAuthenticator.removeBiometricPassword()
                cell.contextView.setToggleOn(false, animated: true)
            } catch {
                bannerController?.presentErrorBanner(
                    title: String(localized: "title-error"),
                    message: String(localized: "local-authentication-disabled-error-message")
                )
                cell.contextView.setToggleOn(true, animated: false)
            }
        } else {
            cell.contextView.setToggleOn(true, animated: true)
        }
    }
}

extension SecretDeveloperMenuViewController {
    private func presentDisabledLocalAuthenticationAlert() {
        let alertController = UIAlertController(
            title: String(localized: "local-authentication-go-settings-title"),
            message: String(localized: "local-authentication-go-settings-text"),
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: String(localized: "title-go-to-settings"), style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: String(localized: "title-cancel"), style: .cancel) { [weak self] _ in
            guard let self = self else {
                return
            }

            let indexPath = IndexPath(item: 1, section: 0)
            guard let cell = self.securitySettingsView.collectionView.cellForItem(at: indexPath) as? SettingsToggleCell else {
                return
            }
            
            cell.contextView.setToggleOn(!cell.contextView.isToggleOn, animated: true)
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
