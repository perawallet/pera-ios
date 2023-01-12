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

//   AccountImportFlowCoordinator.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils


final class AccountImportFlowCoordinator {
    private unowned let presentingScreen: UIViewController
    private var session: Session?

    init(
        presentingScreen: UIViewController,
        session: Session?
    ) {
        self.presentingScreen = presentingScreen
        self.session = session
    }
}

extension AccountImportFlowCoordinator {
    func launch(qrBackupParameters: QRBackupParameters?) {
        guard let qrBackupParameters else {
            openIntroductionScreen()
            return
        }

        openBackupScreen(with: qrBackupParameters, on: presentingScreen)
    }

    private func openIntroductionScreen() {
        let introductionScreen = Screen.importAccountIntroduction { [weak self] event, introductionScreen in
            guard let self else {
                return
            }

            switch event {
            case .didStart:
                self.openQRScannerScreen(on: introductionScreen)
            }
        }
        presentingScreen.open(introductionScreen, by: .push)
    }

    private func openBackupScreen(with parameters: QRBackupParameters, on screen: UIViewController) {
        let backupScreen = Screen.importAccountFetchBackup(parameters) { [weak self] event, backupScreen in
            guard let self else {
                return
            }

            switch event {
            case .didFetchBackup(let backup):
                let accounts = self.getEncryptedAccounts(from: backup, with: parameters)
            case .didFailToFetchBackup(let error):
                // route to error screen
                break
            }
        }

        screen.open(backupScreen, by: .push)
    }

    private func openQRScannerScreen(on screen: UIViewController) {
        let qrScannerScreen = Screen.importAccountQRScanner { [weak self] event, qrScannerScreen in
            guard let self else {
                return
            }

            switch event {
            case .didReadBackup(let parameters):
                self.openBackupScreen(with: parameters, on: qrScannerScreen)
            }
        }
        screen.open(qrScannerScreen, by: .push)
    }

    private func getEncryptedAccounts(from backup: Backup, with qrBackupParameters: QRBackupParameters) -> [Account] {
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
            let users = try? jsonDecoder.decode([EncodedUser].self, from: decryptedData)
        } else {
            // TODO: Handle Error Here
        }

        return []
    }
}

struct EncodedUser: JSONModel {
    let name: String
    let private_key: String
}
