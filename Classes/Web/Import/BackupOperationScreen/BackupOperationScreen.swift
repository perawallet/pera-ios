// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BackupOperationScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import MagpieCore
import MagpieHipo
import MagpieExceptions

final class BackupOperationScreen: BaseViewController {
    typealias EventHandler = (Event, BackupOperationScreen) -> Void

    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var loadingView = Label()
    private lazy var theme = BackupOperationScreenTheme()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!,
        bannerController: bannerController
    )

    private let backupParameters: QRBackupParameters

    init(configuration: ViewControllerConfiguration, backupParameters: QRBackupParameters) {
        self.backupParameters = backupParameters
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addLoadingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAccounts()
    }

    private func addLoadingView() {
        loadingView.customizeAppearance(theme.loading)
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(theme.loadingHorizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}

extension BackupOperationScreen {
    private func fetchAccounts() {
        api?.fetchBackupDetail(backupParameters.id) { [weak self] apiResponse in
            guard let self else { return }
            switch apiResponse {
            case .success(let encryptedBackup):
                self.decryptAccounts(from: encryptedBackup)
            case .failure(_, let model):
                self.eventHandler?(.didFailToFetchBackup(.networkFailed(model)), self)
            }
        }
    }

    private func decryptAccounts(
        from backup: Backup
    ) {
        let encryptionKey = backupParameters.encryptionKey
        let encryptedContentInString = backup.encryptedContent
        let encryptedDataByteArray = encryptedContentInString
            .convertToByteArray(using: ",")
        let encryptedData = Data(bytes: encryptedDataByteArray)

        let cryptor = Cryptor(key: encryptionKey)

        asyncBackground {
            [weak self] in
            guard let self else { return }

            let decryptedContent = cryptor.decrypt(data: encryptedData)

            guard let decryptedData = decryptedContent?.data else {
                asyncMain {
                    self.eventHandler?(.didFailToFetchBackup(.decryption), self)
                }
                return
            }

            do {
                let encodedAccounts = try [EncodedAccount].decoded(decryptedData)
                asyncMain {
                    self.importEncodedAccounts(encodedAccounts)
                }
            } catch {
                asyncMain {
                    self.eventHandler?(.didFailToFetchBackup(.serialization(error)), self)
                }
            }
        }
    }

    private func importEncodedAccounts(_ encodedAccounts: [EncodedAccount]) {
        guard let session, !encodedAccounts.isEmpty else {
            eventHandler?(.didFailToFetchBackup(.notImportableAccountFound), self)
            return
        }

        var importableAccounts: [AccountInformation] = []
        var unimportedAccounts: [AccountInformation] = []

        let preferredOrder = sharedDataController.getPreferredOrderForNewAccount()

        do {
            let transferAccounts = try convertEncodedAccountsToTransferAccounts(
                from: encodedAccounts,
                preferredOrder: preferredOrder
            )

            for transferAccount in transferAccounts {
                let accountAddress = transferAccount.accountInformation.address
                let accountAddressInSharedCollection = sharedDataController.accountCollection[accountAddress]?.value.address

                if accountAddress == accountAddressInSharedCollection {
                    unimportedAccounts.append(transferAccount.accountInformation)
                    continue
                }

                session.savePrivate(transferAccount.privateKey, for: accountAddress)
                importableAccounts.append(transferAccount.accountInformation)
            }
        } catch {
            eventHandler?(.didFailToFetchBackup(.invalidPrivateKey), self)
        }

        saveUser(with: importableAccounts)
        completeBackupImport(importedAccounts: importableAccounts, unimportedAccounts: unimportedAccounts)
    }

    private func saveUser(with accounts: [AccountInformation]) {
        guard let session else {
            return
        }

        let authenticatedUser = session.authenticatedUser ?? User()
        authenticatedUser.addAccounts(accounts)

        pushNotificationController.sendDeviceDetails()

        NotificationCenter.default.post(
            name: .didAddAccount,
            object: self
        )

        session.authenticatedUser = authenticatedUser
    }

    private func completeBackupImport(
        importedAccounts: [AccountInformation],
        unimportedAccounts: [AccountInformation]
    ) {
        eventHandler?(
            .didCompleteImport(
                importedAccounts: importedAccounts.map({.init(localAccount: $0)}),
                unimportedAccounts: unimportedAccounts.map({.init(localAccount: $0)})
            ),
            self
        )
    }

    private func convertEncodedAccountsToTransferAccounts(
        from encodedAccounts: [EncodedAccount],
        preferredOrder: Int
    ) throws -> [TransferAccount] {
        var currentPreferredOrder = preferredOrder
        var transferAccounts: [TransferAccount] = []

        for encodedAccount in encodedAccounts {
            var error: NSError?
            guard let address = AlgorandSDK().addressFrom(encodedAccount.privateKey, error: &error) else {
                throw BackupOperationError.invalidPrivateKey
            }
            let accountInformation = AccountInformation(
                address: address,
                name: encodedAccount.name,
                type: .standard,
                preferredOrder: currentPreferredOrder
            )
            transferAccounts.append(
                TransferAccount(
                    privateKey: encodedAccount.privateKey,
                    accountInformation: accountInformation
                )
            )
            currentPreferredOrder = currentPreferredOrder.advanced(by: 1)
        }

        return transferAccounts
    }
}

extension BackupOperationScreen {
    private struct TransferAccount {
        let privateKey: Data
        let accountInformation: AccountInformation
    }
}

extension BackupOperationScreen {
    enum Event {
        case didCompleteImport(importedAccounts: [Account], unimportedAccounts: [Account])
        case didFailToFetchBackup(BackupOperationError)
    }
}

enum BackupOperationError: Error {
    case networkFailed(HIPAPIError?)
    case decryption
    case serialization(Error)
    case notImportableAccountFound
    case invalidPrivateKey
}
