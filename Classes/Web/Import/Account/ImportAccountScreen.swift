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

//   ImportAccountScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import MagpieCore
import MagpieHipo
import MagpieExceptions
import UIKit

final class ImportAccountScreen: BaseViewController {
    typealias EventHandler = (Event, ImportAccountScreen) -> Void

    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var loadingView = UIView()
    private lazy var imageView = ImageView()
    private lazy var animationImageView = LottieImageView()
    private lazy var titleView = Label()
    private lazy var theme = ImportAccountScreenTheme()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private let importAccountRequest: ImportAccountRequest

    init(configuration: ViewControllerConfiguration, request: ImportAccountRequest) {
        self.importAccountRequest = request
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addLoading()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch importAccountRequest {
        case .qr(let qrBackupParameters):
            fetchAccounts(backupParameters: qrBackupParameters)
        case .recoverHDWallet(let mnemonic):
            recoverHDWalletAccounts(with: mnemonic)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAnimation()
    }
    
    private func addLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading.trailing == theme.horizontalPadding
        }
        
        addImage()
        addTitle()
    }
    
    private func addImage() {
        imageView.customizeAppearance(theme.image)
        loadingView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing == 0
        }
        
        if let image = getAnimationName() {
            animationImageView.setAnimation(image)
            imageView.addSubview(animationImageView)
            animationImageView.snp.makeConstraints {
                $0.center == imageView.snp.center
            }
        }
    }
    
    private func addTitle() {
        titleView.customizeAppearance(theme.title)
        loadingView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == imageView.snp.bottom + theme.titleTopPadding
            $0.leading.trailing.bottom == 0
        }
    }
    
    private func getAnimationName() -> String? {
        let suffix: String = "dots"
        let root: String
        switch traitCollection.userInterfaceStyle {
        case .dark: root = "dark"
        default: root = "light"
        }
        return root + "-" + suffix
    }
    
    private func playAnimation() {
        animationImageView.play(with: LottieImageView.Configuration())
    }
    
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        if let image = getAnimationName() {
            animationImageView.setAnimation(image)
            playAnimation()
        }
    }
}

extension ImportAccountScreen {
    private func fetchAccounts(
        backupParameters: QRBackupParameters
    ) {
        api?.fetchBackupDetail(backupParameters.id) { [weak self] apiResponse in
            guard let self else { return }
            switch apiResponse {
            case .success(let encryptedBackup):
                self.decryptAccounts(from: encryptedBackup, backupParameters: backupParameters)
            case .failure(_, let model):
                self.eventHandler?(.didFailToImport(.networkFailed(model)), self)
            }
        }
    }

    private func decryptAccounts(
        from backup: Backup,
        backupParameters: QRBackupParameters
    ) {
        asyncBackground {
            [weak self] in
            guard
                let self
            else {
                return
            }

            let encryptionKey = backupParameters.encryptionKey
            let encryptedData = self.extractEncryptedData(from: backup)
            let cryptor = Cryptor(key: encryptionKey)
            let decryptedContent = cryptor.decrypt(data: encryptedData)

            guard let decryptedData = decryptedContent.data else {
                self.publish(.didFailToImport(.decryption))
                return
            }

            do {
                let accountParameters = try [AccountImportParameters.APIModel]
                    .decoded(decryptedData)
                    .map { AccountImportParameters.init($0) }

                asyncMain {
                    self.importAccounts(from: accountParameters)
                }
            } catch {
                self.publish(.didFailToImport(.serialization(error)))
            }
        }
    }

    private func extractEncryptedData(from backup: Backup) -> Data {
        let content = backup.encryptedContent
        if let base64Data = Data(base64Encoded: content) {
            return base64Data
        } else {
            let byteArray = content.convertToByteArray(using: ",")
            return Data(bytes: byteArray)
        }
    }

    private func importAccounts(from parameters: [AccountImportParameters]) {
        guard let session, !parameters.isEmpty else {
            eventHandler?(.didFailToImport(.notImportableAccountFound), self)
            return
        }

        var importableAccounts: [AccountInformation] = []
        var unimportedAccounts: [AccountInformation] = []

        do {
            let transferAccounts = try convertAccountParametersToTransferAccounts(
                from: parameters
            )

            for transferAccount in transferAccounts {
                if sharedDataController.accountCollection[transferAccount.accountInformation.address] != nil {
                    unimportedAccounts.append(transferAccount.accountInformation)
                } else {
                    if let privateKey = transferAccount.privateKey {
                        session.savePrivate(privateKey, for: transferAccount.accountInformation.address)
                    }
                    importableAccounts.append(transferAccount.accountInformation)
                }
            }
        } catch {
            eventHandler?(.didFailToImport(.invalidPrivateKey), self)
        }

        saveAccounts(importableAccounts)

        completeImporting(
            imported: importableAccounts,
            unimported: unimportedAccounts,
            parameters: parameters
        )
    }

    private func saveAccounts(_ accounts: [AccountInformation]) {
        guard let session else {
            return
        }

        let authenticatedUser = session.authenticatedUser ?? User()
        authenticatedUser.addAccounts(accounts)

        pushNotificationController.sendDeviceDetails()

        session.authenticatedUser = authenticatedUser
    }

    private func completeImporting(
        imported: [AccountInformation],
        unimported: [AccountInformation],
        parameters: [AccountImportParameters]
    ) {
        eventHandler?(
            .didCompleteImport(
                Result(
                    importedAccounts: imported.map({.init(localAccount: $0)}),
                    unimportedAccounts: unimported.map({.init(localAccount: $0)}),
                    parameters: parameters
                )
            ),
            self
        )
    }

    private func convertAccountParametersToTransferAccounts(
        from accountParameters: [AccountImportParameters]
    ) throws -> [TransferAccount] {
        var currentPreferredOrder = sharedDataController.getPreferredOrderForNewAccount()
        var transferAccounts: [TransferAccount] = []

        for accountParameter in accountParameters {
            guard let privateKey = accountParameter.privateKey else {
                continue
            }

            let accountAddress = accountParameter.address
            
            let accountInformation = AccountInformation(
                address: accountAddress,
                name: accountParameter.name ?? accountAddress.shortAddressDisplay,
                isWatchAccount: accountParameter.accountType.rawAccountType.isWatch,
                preferredOrder: currentPreferredOrder,
                isBackedUp: true
            )
            transferAccounts.append(
                TransferAccount(
                    privateKey: privateKey,
                    accountInformation: accountInformation
                )
            )
            currentPreferredOrder = currentPreferredOrder.advanced(by: 1)
        }

        return transferAccounts
    }

    private func publish(
        _ event: Event
    ) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event, self)
        }
    }
}

extension ImportAccountScreen {
    private func recoverHDWalletAccounts(with mnemonics: String) {
        Task { @MainActor in
            do {
                var hdWalletId: String?
                let accounts: [RecoveredAddress] = try await hdWalletService
                    .recoverAccounts(fromMnemonic: mnemonics, api: api)
                    .map {
                        let alreadyImported = session?.authenticatedUser?.account(address: $0.address) != nil
                        if alreadyImported {
                            hdWalletId = session?.authenticatedUser?.account(address: $0.address)?.hdWalletAddressDetail?.walletId
                        }
                        return RecoveredAddress(address: $0.address, accountIndex: $0.accountIndex, addressIndex: $0.addressIndex, mainCurrency: Double($0.algoValue) ?? 0.0, secondaryCurrency: Double($0.usdValue) ?? 0.0, alreadyImported: alreadyImported)
                    }
                
                eventHandler?(
                    .didCompleteHDWalletImport(accounts, hdWalletId),
                    self
                )
            } catch {
                eventHandler?(
                    .didFailToImport(.invalidSeed),
                    self
                )
            }
        }
    }
}

extension ImportAccountScreen {
    enum ImportAccountRequest {
        case qr(QRBackupParameters)
        case recoverHDWallet(String)
    }
    
    enum Event {
        case didCompleteImport(Result)
        case didCompleteHDWalletImport([RecoveredAddress], String?)
        case didFailToImport(ImportAccountScreenError)
    }

    struct Result {
        let importedAccounts: [Account]
        let unimportedAccounts: [Account]
        let parameters: [AccountImportParameters]
    }
}

enum ImportAccountScreenError: Error {
    case networkFailed(HIPAPIError?)
    case decryption
    case serialization(Error)
    case notImportableAccountFound
    case invalidPrivateKey
    case invalidSeed
    case unsupportedVersion(version: String)
    case unsupportedAction
}
