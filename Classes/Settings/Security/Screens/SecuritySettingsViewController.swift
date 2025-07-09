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

//
//   SecuritySettingsViewController.swift

import UIKit

final class SecuritySettingsViewController: BaseViewController {
    
    private let rekeySupportFooterText = String(localized: "security-settings-section-footer")
    
    private lazy var theme = Theme()
    private lazy var securitySettingsView = SecuritySettingsView()
    
    private var settings: [[SecuritySettings]] = [[.pinCodeActivation, .rekeySupport]]
    private var pinActiveSettings: [SecuritySettings] = [.pinCodeChange, .localAuthentication]
    private var sectionHeaderTitles: [Int: String] = [:]
    private var sectionFooterTitles: [Int: String] = [:]
    
    private lazy var localAuthenticator = LocalAuthenticator(session: session!)
    
    private var isRekeySupported: Bool {
        get { PeraUserDefaults.isRekeySupported ?? false }
        set { PeraUserDefaults.isRekeySupported = newValue }
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = String(localized: "security-settings-title")
    }

    override func linkInteractors() {
        securitySettingsView.collectionView.delegate = self
        securitySettingsView.collectionView.dataSource = self
    }
    
    override func prepareLayout() {
        addSecuritySettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkPINCodeActivation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isViewFirstLoaded else {
            return
        }

        checkPINCodeActivation()
    }
}

extension SecuritySettingsViewController {
    private func addSecuritySettingsView() {
        view.addSubview(securitySettingsView)
        
        securitySettingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SecuritySettingsViewController {
    private func checkPINCodeActivation() {
        let hasPassword = session?.hasPassword() ?? false

        if hasPassword {
            createSettingsWithPreferences()
        } else {
            createSettingsWithoutPreferences()
        }
    }
    
    private func createSettingsWithPreferences() {
        settings = [[.pinCodeActivation, .rekeySupport], [.pinCodeChange, .localAuthentication]]
        sectionHeaderTitles = [1 : String(localized: "security-settings-section-header")]
        sectionFooterTitles = [0 : rekeySupportFooterText]
        securitySettingsView.collectionView.reloadData()
    }
    
    private func createSettingsWithoutPreferences() {
        settings = [[.pinCodeActivation, .rekeySupport]]
        sectionHeaderTitles = [:]
        sectionFooterTitles = [0 : rekeySupportFooterText]
        securitySettingsView.collectionView.reloadData()
    }
}

extension SecuritySettingsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        sectionHeaderTitles.keys.contains(section) ? CGSize(theme.headerSize) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerHeight = rekeySupportFooterText.height(withConstrained: collectionView.bounds.width, font: SecuritySettingsFooterView.usedFont)
        return sectionFooterTitles.keys.contains(section) ? CGSize(width: collectionView.bounds.width, height: footerHeight) : .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = settings[safe: indexPath.section],
              let setting = section[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        if setting == .pinCodeChange {
            open(
                .choosePassword(mode: .verifyOld, flow: nil),
                by: .push
            )
        }
    }
}

extension SecuritySettingsViewController: UICollectionViewDataSource {
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
        case .pinCodeActivation:
            let cell = collectionView.dequeue(SettingsToggleCell.self, at: indexPath)
            cell.delegate = self
            let hasPassword = session?.hasPassword() ?? false
            cell.bindData(SettingsToggleViewModel(setting: setting, isOn: hasPassword))
            return cell
        case .pinCodeChange:
            let cell = collectionView.dequeue(SettingsDetailCell.self, at: indexPath)
            cell.bindData(SettingsDetailViewModel(settingsItem: setting))
            return cell
        case .localAuthentication:
            let hasBiometricAuthentication = localAuthenticator.hasAuthentication()
            let cell = collectionView.dequeue(SettingsToggleCell.self, at: indexPath)
            cell.delegate = self
            cell.bindData(SettingsToggleViewModel(setting: setting, isOn: hasBiometricAuthentication))
            return cell
        case .rekeySupport:
            let cell = collectionView.dequeue(SettingsToggleCell.self, at: indexPath)
            cell.delegate = self
            cell.bindData(SettingsToggleViewModel(setting: setting, isOn: isRekeySupported))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let title = sectionHeaderTitles[indexPath.section] else { fatalError("No title") }
            let headerView = collectionView.dequeueHeader(SingleGrayTitleHeaderSuplementaryView.self, at: indexPath)
            headerView.bindData(SingleGrayTitleHeaderViewModel(title))
            headerView.contextView.topPadding = 32.0
            return headerView
        case UICollectionView.elementKindSectionFooter:
            guard let title = sectionFooterTitles[indexPath.section] else { fatalError("No title") }
            let footerView = collectionView.dequeueFooter(SecuritySettingsFooterView.self, at: indexPath)
            footerView.title = title
            return footerView
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension SecuritySettingsViewController: SettingsToggleCellDelegate {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool) {
        guard let indexPath = securitySettingsView.collectionView.indexPath(for: settingsToggleCell),
            let section = settings[safe: indexPath.section],
            let setting = section[safe: indexPath.item] else {
            return
        }
        
        switch setting {
        case .pinCodeActivation:
            let mode: ChoosePasswordViewController.Mode = value ? .resetPassword(flow: .initial) : .deletePassword
            open(
                .choosePassword(mode: mode, flow: nil),
                by: .push
            )
        case .localAuthentication:
            if !value {
                let controller = open(
                    .choosePassword(mode: .confirm(flow: .settings), flow: nil),
                    by: .push
                ) as? ChoosePasswordViewController
                controller?.delegate = self
                return
            }

            do {
                try localAuthenticator.setBiometricPassword()
            } catch let error as LAError {
                defer {
                    settingsToggleCell.contextView.setToggleOn(false, animated: true)
                }

                switch error {
                case .unexpected:
                    presentDisabledLocalAuthenticationAlert()
                default:
                    break
                }
            } catch {
                presentDisabledLocalAuthenticationAlert()
                settingsToggleCell.contextView.setToggleOn(false, animated: true)
            }
        case .rekeySupport:
            isRekeySupported = value
        case .pinCodeChange:
            return
        }
    }
}

extension SecuritySettingsViewController: ChoosePasswordViewControllerDelegate {
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

extension SecuritySettingsViewController {
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
