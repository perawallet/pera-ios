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

final class AccountImportFlowCoordinator {
    private unowned let presentingScreen: UIViewController
    private let api: ALGAPI
    private var session: Session?
    private var qrBackupParameters: QRBackupParameters?

    init(
        presentingScreen: UIViewController,
        api: ALGAPI,
        session: Session?
    ) {
        self.presentingScreen = presentingScreen
        self.api = api
        self.session = session
    }
}

extension AccountImportFlowCoordinator {
    func launch(qrBackupParameters: QRBackupParameters) {
        self.qrBackupParameters = qrBackupParameters
    }

    private func processEncryptedContent(_ content: Backup) {
        guard let qrBackupParameters else {
            return
        }

        // TODO: Will add a JSON encoder/decoder here to encrypt/decrypt all contents using it.
        let encryptionKey = qrBackupParameters.encryptionKey
        let encryptedContentInString = content.encryptedContent
        let encryptedDataByteArray = encryptedContentInString
            .convertToByteArray(using: ",")
        let encryptedData = Data(bytes: encryptedDataByteArray)

        let cryptor = Cryptor(key: encryptionKey)
        let decryptedContent = cryptor.decrypt(data: encryptedData)

        if let decryptedData = decryptedContent?.data {
            // success
            print(decryptedData)
        } else {
            print("error")
        }
    }
}
