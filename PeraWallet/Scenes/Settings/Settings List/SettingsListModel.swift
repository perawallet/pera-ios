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

//   SettingsListModel.swift

import Foundation
import DeveloperToolsSupport
import pera_wallet_core

// MARK: - View Model

final class SettingsListViewModel: ObservableObject {
    
    struct Section: Identifiable {
        let id: Int
        let title: String
        let rows: [Row]
    }
    
    enum Row {
        case security
        case contacts
        case notifications
        case walletConnect
        case passkeys
        case currency
        case theme
        case help
        case rateApp
        case termsAndServices
        case privacyPolicy
        case developer
    }
    
    @Published fileprivate(set) var sections: [Section] = []
    @Published fileprivate(set) var appVersion: String = ""
}

// MARK: - Model

protocol SettingsListModelable {
    var viewModel: SettingsListViewModel { get }
    func registerAnalyticsEvent(_ event: any ALGAnalyticsEvent)
}

final class SettingsListModel: SettingsListModelable {
    
    // MARK: - SettingsListModelable
    
    var viewModel = SettingsListViewModel()
    
    // MARK: - Initialisers
    
    init(appVersion: String) {
        setupData(appVersion: appVersion)
    }
    
    // MARK: - Setups
    
    private func setupData(appVersion: String) {
        let isLiquidAuthEnabled = AppDelegate.shared?.appConfiguration.featureFlagService.isEnabled(.liquidAuthEnabled) ?? false
        viewModel.sections = [
            isLiquidAuthEnabled ? .accountSectionWithPassKeys : .accountSection,
            .appPreferencesSection,
            .supportSection
        ]
        viewModel.appVersion = appVersion
    }
    
    // MARK: - Setups
    
    func registerAnalyticsEvent(_ event: any ALGAnalyticsEvent) {
        AppDelegate.shared?.appConfiguration.analytics.track(event)
    }
}

extension SettingsListViewModel.Section {
    
    static var accountSection: Self {
        Self(
            id: 0,
            title: String(localized: "title-account"),
            rows: [
                .security,
                .contacts,
                .notifications,
                .walletConnect
            ]
        )
    }
    
    static var accountSectionWithPassKeys: Self {
        Self(
            id: 0,
            title: String(localized: "title-account"),
            rows: [
                .security,
                .contacts,
                .notifications,
                .walletConnect,
                .passkeys
            ]
        )
    }
    
    static var appPreferencesSection: Self {
        Self(
            id: 1,
            title: String(localized: "settings-sections-appPreferences"),
            rows: [
                .currency,
                .theme
            ]
        )
    }
    
    static var supportSection: Self {
        Self(
            id: 2,
            title: String(localized: "settings-sections-support"),
            rows: [
                .help,
                .rateApp,
                .termsAndServices,
                .privacyPolicy,
                .developer
            ]
        )
    }
}

extension SettingsListViewModel.Row: Identifiable {
    
    var id: String {
        switch self {
        case .security:
            return "security"
        case .contacts:
            return "contacts"
        case .notifications:
            return "notifications"
        case .walletConnect:
            return "walletConnect"
        case .passkeys:
            return "passkeys"
        case .currency:
            return "currency"
        case .theme:
            return "theme"
        case .help:
            return "help"
        case .rateApp:
            return "rateApp"
        case .termsAndServices:
            return "termsAndServices"
        case .privacyPolicy:
            return "privacyPolicy"
        case .developer:
            return "developer"
        }
    }
}

extension SettingsListViewModel.Row {
    
    var icon: ImageResource {
        switch self {
        case .security:
            return .Settings.Icon.security
        case .contacts:
            return .Settings.Icon.contacts
        case .notifications:
            return .Settings.Icon.notifications
        case .walletConnect:
            return .Settings.Icon.walletConnect
        case .passkeys:
            return .Settings.Icon.passkeys
        case .currency:
            return .Settings.Icon.currency
        case .theme:
            return .Settings.Icon.moon
        case .help:
            return .Settings.Icon.feedback
        case .rateApp:
            return .Settings.Icon.star
        case .termsAndServices, .privacyPolicy:
            return .Settings.Icon.terms
        case .developer:
            return .Settings.Icon.developer
        }
    }
    
    var title: String {
        switch self {
        case .security:
            return String(localized: "security-settings-title")
        case .contacts:
            return String(localized: "contacts-title")
        case .notifications:
            return String(localized: "notifications-title")
        case .walletConnect:
            return String(localized: "settings-wallet-connect-title")
        case .passkeys:
            return String(localized: "settings-passkeys-title")
        case .currency:
            return String(localized: "settings-currency")
        case .theme:
            return String(localized: "settings-theme-set")
        case .help:
            return String(localized: "settings-support-title")
        case .rateApp:
            return String(localized: "settings-rate-title")
        case .termsAndServices:
            return String(localized: "title-terms-and-services")
        case .privacyPolicy:
            return String(localized: "title-privacy-policy")
        case .developer:
            return String(localized: "settings-developer")
        }
    }
}

// MARK: - Mocks

protocol SettingsListModelMockable: SettingsListModelable {}

extension SettingsListModelMockable {
    func update(appVersion: String) { viewModel.appVersion = appVersion }
    func update(sections: [SettingsListViewModel.Section]) { viewModel.sections = sections }
}
