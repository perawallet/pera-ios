// Copyright 2025 Pera Wallet, LDA

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
import Combine

// MARK: - View Model

final class SettingsListViewModel: ObservableObject {
    
    struct Section: Identifiable {
        let id: Int
        let title: String
        let rows: [Row]
    }
    
    enum Row {
        case secureBackup(accountsNeedBackupCount: Int)
        case security
        case contacts
        case notifications
        case walletConnect
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
}

final class SettingsListModel: SettingsListModelable {
    
    // MARK: - SettingsListModelable
    
    var viewModel = SettingsListViewModel()
    
    // MARK: - Properties
    
    private let accountsService: AccountsServicable
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Legacy Properties
    
    private let legacySessionManager: Session
    
    // MARK: - Initialisers
    
    init(accountsService: AccountsServicable, appVersion: String, legacySessionManager: Session) {
        self.accountsService = accountsService
        self.legacySessionManager = legacySessionManager
        viewModel.appVersion = appVersion
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        accountsService.accounts.publisher
            .map { $0.filter(\.isBackupable) }
            .map { $0.filter { [weak self] in self?.legacySessionManager.backups[$0.address] == nil }}
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.handle(accountsNeedBackupCount: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Handlers
    
    private func handle(accountsNeedBackupCount: Int) {
        viewModel.sections = [
            .accountSection(accountsNeedBackupCount: accountsNeedBackupCount),
            .appPreferencesSection,
            .supportSection
        ]
    }
}

extension SettingsListViewModel.Section {
    
    static func accountSection(accountsNeedBackupCount: Int) -> Self {
        Self(
            id: 0,
            title: String(localized: "title-account"),
            rows: [
                .secureBackup(accountsNeedBackupCount: accountsNeedBackupCount),
                .security,
                .contacts,
                .notifications,
                .walletConnect
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
        case let .secureBackup(accountsNeedBackupCount):
            return "secureBackup-\(accountsNeedBackupCount)"
        case .security:
            return "security"
        case .contacts:
            return "contacts"
        case .notifications:
            return "notifications"
        case .walletConnect:
            return "walletConnect"
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
        case .secureBackup:
            return .Settings.Icon.backup
        case .security:
            return .Settings.Icon.security
        case .contacts:
            return .Settings.Icon.contacts
        case .notifications:
            return .Settings.Icon.notifications
        case .walletConnect:
            return .Settings.Icon.walletConnect
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
        case .secureBackup:
            return String(localized: "settings-secure-backup-title")
        case .security:
            return String(localized: "security-settings-title")
        case .contacts:
            return String(localized: "contacts-title")
        case .notifications:
            return String(localized: "notifications-title")
        case .walletConnect:
            return String(localized: "settings-wallet-connect-title")
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
    
    var subtitle: String? {
        switch self {
        case let .secureBackup(accountsNeedBackupCount):
            return String(localized: "settings-secure-backup-subtitle-\(accountsNeedBackupCount)")
        case .security, .contacts, .notifications, .walletConnect, .currency, .theme, .help, .rateApp, .termsAndServices, .privacyPolicy, .developer:
            return nil
        }
    }
}

// MARK: - Mocks

protocol SettingsListModelMockable: SettingsListModelable {}

extension SettingsListModelMockable {
    func update(appVersion: String) { viewModel.appVersion = appVersion }
    func update(sections: [SettingsListViewModel.Section]) { viewModel.sections = sections }
}
