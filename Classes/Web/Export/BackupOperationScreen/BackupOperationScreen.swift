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

final class BackupOperationScreen: BaseViewController {
    typealias EventHandler = (Event, BackupOperationScreen) -> Void

    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var loadingTitleView = Label()
    private lazy var theme = BackupOperationScreenTheme()

    private let backupInformations: QRBackupInformations

    init(configuration: ViewControllerConfiguration, backupInformations: QRBackupInformations) {
        self.backupInformations = backupInformations
        super.init(configuration: configuration)
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
        loadingTitleView.customizeAppearance(theme.loading)
        view.addSubview(loadingTitleView)
        loadingTitleView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(theme.loadingHorizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}

extension BackupOperationScreen {
    private func fetchAccounts() {
        api?.fetchBackupDetail(backupInformations.identifier) { [weak self] apiResponse in
            guard let self else { return }
            switch apiResponse {
            case .failure(let apiError, _):
                self.eventHandler?(.didFailedToFetchEncryptedBackup(apiError), self)
            case .success(let encryptedBackup):
                self.eventHandler?(.didFetchedEncryptedBackup(encryptedBackup), self)
            }
        }
    }
}

extension BackupOperationScreen {
    enum Event {
        case didFetchedEncryptedBackup(EncryptedBackup)
        case didFailedToFetchEncryptedBackup(APIError)
    }
}
