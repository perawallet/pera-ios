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
//   SettingsDataSource.swift

import UIKit

final class SettingsDataSource: NSObject {
    weak var delegate: SettingsDataSourceDelegate?
    
    private(set) lazy var sections: [GeneralSettings] = [.account, .appPreferences, .support]
    private(set) lazy var settings: [[Settings]] = [accountSettings, appPreferenceSettings, supportSettings]
    private(set) lazy var accountSettings: [AccountSettings] = [.backup, .security, .notifications, .walletConnect]
    private(set) lazy var appPreferenceSettings: [AppPreferenceSettings] = {
        var settings: [AppPreferenceSettings] = [.rewards, .language, .currency]
        if #available(iOS 13.0, *) {
            settings.append(.appearance)
        }
        return settings
    }()
    private(set) lazy var supportSettings: [SupportSettings] = [.feedback, .appReview, .termsAndServices, .privacyPolicy, .developer]
    
    private var session: Session?
    
    init(session: Session?) {
        super.init()
        self.session = session
    }
}

extension SettingsDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let section = sections[safe: indexPath.section] {
            switch section {
            case .account:
                if let setting = accountSettings[safe: indexPath.item] {
                    switch setting {
                    case .backup, .security, .notifications, .walletConnect:
                        return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
                    }
                }
            case .appPreferences:
                if let setting = appPreferenceSettings[safe: indexPath.item] {
                    switch setting {
                    case .rewards:
                        let rewardDisplayPreference = session?.rewardDisplayPreference == .allowed
                        return setSettingsToggleCell(from: setting, isOn: rewardDisplayPreference, in: collectionView, at: indexPath)
                    case .language, .currency, .appearance:
                        return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
                    }
                }
            case .support:
                if let setting = supportSettings[safe: indexPath.item] {
                    switch setting {
                    case .feedback, .appReview, .termsAndServices, .privacyPolicy, .developer:
                        return setSettingsDetailCell(from: setting, in: collectionView, at: indexPath)
                    }
                }
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

extension SettingsDataSource: SettingsFooterSupplementaryViewDelegate {
    func settingsFooterSupplementaryViewDidTapLogoutButton(_ settingsFooterSupplementaryView: SettingsFooterSupplementaryView) {
        delegate?.settingsDataSourceDidTapLogout(self, settingsFooterSupplementaryView)
    }
}

extension SettingsDataSource: SettingsToggleCellDelegate {
    func settingsToggleCell(_ settingsToggleCell: SettingsToggleCell, didChangeValue value: Bool) {
        delegate?.settingsDataSource(self, settingsToggleCell, didchangeValue: value)
    }
}

protocol SettingsDataSourceDelegate: AnyObject {
    func settingsDataSource(
        _ settingsDataSource: SettingsDataSource,
        _ settingsToggleCell: SettingsToggleCell,
        didchangeValue value: Bool
    )
    func settingsDataSourceDidTapLogout(
        _ settingsDataSource: SettingsDataSource,
        _ settingsFooterSupplementaryView: SettingsFooterSupplementaryView
    )
}
