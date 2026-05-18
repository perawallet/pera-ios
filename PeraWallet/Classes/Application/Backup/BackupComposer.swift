// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BackupComposer.swift

import pera_wallet_core
import MacaroonUtils

final class BackupComposer: SharedDataControllerObserver {

    enum BackupError: Error {
        case unableToFetchContacts(error: Error)
        case unableToFetchPassKeys(error: Error)
        case unableToCreateJSON(error: Error)
    }

    // MARK: - Properties

    private let session: Session
    private let hdWalletStorage: HDWalletStorage
    private let sharedDataController: SharedDataController
    private let accountsService: AccountsServiceable

    private var sharedDataContinuation: CheckedContinuation<Void, Never>?
    private var sharedDataExpectedCount = 0

    // MARK: - Initialisers

    /// Creates a composer with the dependencies it needs to read user data.
    init(session: Session, hdWalletStorage: HDWalletStorage, sharedDataController: SharedDataController, accountsService: AccountsServiceable) {
        self.session = session
        self.hdWalletStorage = hdWalletStorage
        self.sharedDataController = sharedDataController
        self.accountsService = accountsService
    }

    // MARK: - Actions

    /// Waits for accounts to load and returns a full backup of accounts, contacts, passkeys, auth, and user defaults.
    func backup() async throws(BackupError) -> FullBackup {

        await waitForAccounts()
        await waitForSharedData()

        let accounts = backupAccounts()
        let contacts = try backupContacts()
        let passKeys = try backupPassKeys()
        let auth = backupAuth()
        let localSettings = backupUserDefaults()

        return FullBackup(accounts: accounts, contacts: contacts, passKeys: passKeys, auth: auth, localSettings: localSettings)
    }

    /// Builds a full backup and returns it encoded as JSON data.
    func backupAsJSON() async throws(BackupError) -> Data {

        let backup = try await backup()

        do {
            return try JSONEncoder().encode(backup)
        } catch {
            throw .unableToCreateJSON(error: error)
        }
    }

    private func waitForAccounts() async {
        if !accountsService.accounts.value.isEmpty { return }
        for await _ in accountsService.accounts.publisher.dropFirst().values {
            return
        }
    }

    private func waitForSharedData() async {
        let expected = accountsService.accounts.value.count
        if sharedDataController.accountCollection.count >= expected { return }

        await withCheckedContinuation { continuation in
            sharedDataExpectedCount = expected
            sharedDataContinuation = continuation
            sharedDataController.add(self)
        }
    }
    
    // MARK: - Accounts

    private func backupAccounts() -> [AccountBackup] {
        accountsService.accounts.value
            .sorted { $0.sortingIndex < $1.sortingIndex }
            .compactMap { [weak self] in self?.backup(account: $0) }
    }

    private func backup(account: PeraAccount) -> AccountBackup? {
        switch account.type {
        case .algo25:
            guard let backup = makeAlgo25Backup(account: account) else { return nil }
            return .algo25(backup: backup)
        case .universalWallet:
            guard let backup = makeUniversalWalletBackup(account: account) else { return nil }
            return .universalWallet(backup: backup)
        case .watch:
            let backup = makeWatchAccountBackup(account: account)
            return .watch(backup: backup)
        case .ledger:
            guard let backup = makeLedgerBackup(account: account) else { return nil }
            return .ledger(backup: backup)
        case .joint:
            guard let backup = makeSharedAccountBackup(account: account) else { return nil }
            return .sharedAccount(backup: backup)
        case .invalid:
            let backup = makeInvalidAccountBackup(account: account)
            return .invalid(backup: backup)
        }
    }
    
    private func makeAlgo25Backup(account: PeraAccount) -> Algo25Backup? {
        guard let privateKey = session.privateData(for: account.address), let localAccount = localAccount(peraAccount: account) else { return nil }
        return Algo25Backup(sortingIndex: account.sortingIndex, name: account.titles.primary, address: account.address, authAddress: localAccount.authAddress, privateKey: privateKey, mnemonics: mnemonics(localAccount: localAccount))
    }

    private func makeUniversalWalletBackup(account: PeraAccount) -> UniversalWalletAccountBackup? {

        guard let localAccount = localAccount(peraAccount: account), let walletID = localAccount.hdWalletAddressDetail?.walletId, let seed = try? hdWalletStorage.wallet(id: walletID) else {
            return nil
        }

        let wallet = UniversalWalletAccountBackup.Wallet(seed: seed, mnemonics: mnemonics(localAccount: localAccount))
        return UniversalWalletAccountBackup(sortingIndex: account.sortingIndex, name: account.titles.primary, address: account.address, authAddress: localAccount.authAddress, wallet: wallet)
    }
    
    private func makeWatchAccountBackup(account: PeraAccount) -> WatchAccountBackup {
        WatchAccountBackup(sortingIndex: account.sortingIndex, name: account.titles.primary, address: account.address, authAddress: nil)
    }
    
    private func makeLedgerBackup(account: PeraAccount) -> LedgerBackup? {
        guard let localAccount = localAccount(peraAccount: account), let details = localAccount.ledgerDetail else { return nil }
        return LedgerBackup(sortingIndex: account.sortingIndex, name: account.titles.primary, address: account.address, authAddress: localAccount.authAddress, details: details)
    }
    
    private func makeSharedAccountBackup(account: PeraAccount) -> SharedAccountBackup? {
        guard let localAccount = localAccount(peraAccount: account), let participants = localAccount.jointAccountParticipants else { return nil }
        return SharedAccountBackup(sortingIndex: account.sortingIndex, name: account.titles.primary, address: account.address, authAddress: localAccount.authAddress, participants: participants)
    }
    
    private func makeInvalidAccountBackup(account: PeraAccount) -> InvalidAccountBackup {
        InvalidAccountBackup(sortingIndex: account.sortingIndex, name: account.titles.primary, address: account.address, authAddress: nil)
    }
    
    private func localAccount(peraAccount: PeraAccount) -> Account? {
        sharedDataController.accountCollection[peraAccount.address]?.value
    }
    
    private func mnemonics(localAccount: Account) -> [String] {
        PassphraseUtils.mnemonics(account: localAccount, hdWalletStorage: hdWalletStorage, session: session).mnemonics
    }
    
    // MARK: - Contacts

    private func backupContacts() throws(BackupError) -> [ContactBackup] {

        let contacts: [Contact]
        do {
            contacts = try extract(Contact.fetchAllSyncronous(entity: Contact.entityName))
        } catch {
            throw .unableToFetchContacts(error: error)
        }

        return contacts.compactMap {
            guard let address = $0.address else { return nil }
            return ContactBackup(name: $0.name ?? "", address: address, image: $0.image)
        }
    }

    // MARK: - PassKeys

    private func backupPassKeys() throws(BackupError) -> [PassKeyBackup] {

        let passKeys: [PassKey]
        do {
            passKeys = try extract(PassKey.fetchAllSyncronous(entity: PassKey.entityName))
        } catch {
            throw .unableToFetchPassKeys(error: error)
        }

        return passKeys.map {
            PassKeyBackup(
                origin: $0.origin,
                username: $0.username,
                userHandle: $0.userHandle,
                displayName: $0.displayName,
                address: $0.address,
                credentialId: $0.credentialId,
                lastUsed: $0.lastUsed
            )
        }
    }
    
    // MARK: - Auth

    private func backupAuth() -> AuthBackup {
        AuthBackup(pinCode: session.passwordForBackup())
    }
    
    // MARK: - UserDefaults

    private func backupUserDefaults() -> [String: AnyEncodable] {

        var excludedPrefixes = ["Apple", "com.apple", "NS", "METAL", "AK", "PK", "WebKit", "firebase", "/google", "com.walletconnect", "AddingEmojiKeybordHandled"]
        excludedPrefixes += PeraUserDefaults.Key.allCases.map(\.rawValue)

        var backup: [String: AnyEncodable] = [
            PeraUserDefaults.Key.wasPrivacyTooltipPresented.rawValue: AnyEncodable(PeraUserDefaults.wasPrivacyTooltipPresented),
            PeraUserDefaults.Key.isPrivacyModeEnabled.rawValue: AnyEncodable(PeraUserDefaults.isPrivacyModeEnabled),
            PeraUserDefaults.Key.shouldShowNewAccountAnimation.rawValue: AnyEncodable(PeraUserDefaults.shouldShowNewAccountAnimation),
            PeraUserDefaults.Key.shouldUseLocalCurrencyInSwap.rawValue: AnyEncodable(PeraUserDefaults.shouldUseLocalCurrencyInSwap),
            PeraUserDefaults.Key.isMediaCleanupCompleted.rawValue: AnyEncodable(PeraUserDefaults.isMediaCleanupCompleted),
            PeraUserDefaults.Key.lastAddressUsedInSwapCompleted.rawValue: AnyEncodable(PeraUserDefaults.lastAddressUsedInSwapCompleted),
            PeraUserDefaults.Key.isRekeySupported.rawValue: AnyEncodable(PeraUserDefaults.isRekeySupported),
            PeraUserDefaults.Key.watchedJointAccountInvitations.rawValue: AnyEncodable(PeraUserDefaults.watchedJointAccountInvitations),
            PeraUserDefaults.Key.watchedSignRequestMessage.rawValue: AnyEncodable(PeraUserDefaults.watchedSignRequestMessage),
            PeraUserDefaults.Key.hasJointAccountCreationPopupBeenShown.rawValue: AnyEncodable(PeraUserDefaults.hasJointAccountCreationPopupBeenShown),
            PeraUserDefaults.Key.shouldShowDevMenu.rawValue: AnyEncodable(PeraUserDefaults.shouldShowDevMenu),
            PeraUserDefaults.Key.enableTestCards.rawValue: AnyEncodable(PeraUserDefaults.enableTestCards),
            PeraUserDefaults.Key.overrideRemoteConfigValues.rawValue: AnyEncodable(PeraUserDefaults.overrideRemoteConfigValues),
            PeraUserDefaults.Key.enableTestXOSwapPage.rawValue: AnyEncodable(PeraUserDefaults.enableTestXOSwapPage)
        ]

        UserDefaults.standard.dictionaryRepresentation()
            .filter { key, _ in !excludedPrefixes.contains(where: key.hasPrefix) }
            .forEach { backup[$0.key] = encodableValue(value: $0.value) }

        return backup
    }
    
    // MARK: - Helpers

    private func encodableValue(value: Any) -> AnyEncodable? {

        switch value {
        case let value as Bool where CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID():
            return AnyEncodable(value)
        case let value as Int:
            return AnyEncodable(value)
        case let value as Double:
            return AnyEncodable(value)
        case let value as String:
            return AnyEncodable(value)
        case let value as Data:
            return AnyEncodable(value)
        case let value as Date:
            return AnyEncodable(value)
        case let value as URL:
            return AnyEncodable(value)
        case let value as [Any]:
            let encoded = value.compactMap { encodableValue(value: $0) }
            return encoded.count == value.count ? AnyEncodable(encoded) : nil
        case let value as [String: Any]:
            var encoded: [String: AnyEncodable] = [:]
            for (key, item) in value {
                guard let item = encodableValue(value: item) else { return nil }
                encoded[key] = item
            }
            return AnyEncodable(encoded)
        default:
            return nil
        }
    }
    
    private func extract<T: DBStorable>(_ result: DBOperationResult<T>) throws -> [T] {
        switch result {
        case let .result(object):
            return [object].compactMap { $0 as? T }
        case let .results(objects):
            return objects.compactMap { $0 as? T }
        case let .error(error):
            throw error
        }
    }
    
    // MARK: - SharedDataControllerObserver

    func sharedDataController(_ sharedDataController: SharedDataController, didPublish event: SharedDataControllerEvent) {
        
        guard case .didFinishRunning = event else { return }
        guard sharedDataController.accountCollection.count >= sharedDataExpectedCount else { return }

        sharedDataController.remove(self)
        sharedDataContinuation?.resume()
        sharedDataContinuation = nil
    }
}
