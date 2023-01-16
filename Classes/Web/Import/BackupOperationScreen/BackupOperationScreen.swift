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
                self.processEncryptedAccounts(from: encryptedBackup, with: self.backupParameters)
            case .failure(_, let model):
                self.eventHandler?(.didFailToFetchBackup(model), self)
            }
        }
    }

    private func processEncryptedAccounts(
        from backup: Backup,
        with qrBackupParameters: QRBackupParameters
    ) {
        // TODO: Will add a JSON encoder/decoder here to encrypt/decrypt all contents using it.
        let encryptionKey = qrBackupParameters.encryptionKey
        let encryptedContentInString = backup.encryptedContent
        let encryptedDataByteArray = encryptedContentInString
            .convertToByteArray(using: ",")
        let encryptedData = Data(bytes: encryptedDataByteArray)

        let cryptor = Cryptor(key: encryptionKey)
        let decryptedContent = cryptor.decrypt(data: encryptedData)
        let jsonDecoder = JSONDecoder()

        if let decryptedData = decryptedContent?.data {
            let users = try? jsonDecoder.decode([EncodedAccount].self, from: decryptedData)
            saveAccounts(users)
        } else {
            self.eventHandler?(.didFailToFetchBackup(nil), self)
        }
    }

    private func saveAccounts(_ accounts: [EncodedAccount]?) {
        guard let session, let accounts, !accounts.isEmpty else {
            return
        }

        var importedAccounts: [AccountInformation] = []

        var preferredOrder = sharedDataController.getPreferredOrderForNewAccount()
        for account in accounts {
            guard let accountInformation = account.createAccountInformation(with: preferredOrder) else {
                continue
            }

            let accountAddress = accountInformation.address
            let sessionAccountInformation = session.accountInformation(from: accountAddress)

            if accountInformation == sessionAccountInformation {
                continue
            }

            preferredOrder = preferredOrder.advanced(by: 1)

            session.savePrivate(account.privateKey, for: accountAddress)
            importedAccounts.append(accountInformation)
        }

        let user: User

        if let authenticatedUser = session.authenticatedUser {
            user = authenticatedUser

            for account in importedAccounts {
                authenticatedUser.addAccount(account)
            }

            pushNotificationController.sendDeviceDetails()
        } else {
            user = User(accounts: importedAccounts)
        }

        NotificationCenter.default.post(
            name: .didAddAccount,
            object: self
        )

        session.authenticatedUser = user

        let unimportedAccountsCount = accounts.count - importedAccounts.count

        eventHandler?(.didSaveAccounts(importedAccounts: importedAccounts, unimportedAccountsCount: unimportedAccountsCount), self)
    }
}

extension BackupOperationScreen {
    enum Event {
        case didSaveAccounts(importedAccounts: [AccountInformation], unimportedAccountsCount: Int)
        case didFailToFetchBackup(HIPAPIError?)
    }
}
