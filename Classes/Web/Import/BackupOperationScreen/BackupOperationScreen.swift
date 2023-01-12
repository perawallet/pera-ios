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

    private let backupParameters: QRBackupParameters

    init(configuration: ViewControllerConfiguration, backupParameters: QRBackupParameters) {
        self.backupParameters = backupParameters
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
                self.eventHandler?(.didFetchBackup(encryptedBackup), self)
            case .failure(_, let model):
                self.eventHandler?(.didFailToFetchBackup(model), self)
            }
        }
    }
}

extension BackupOperationScreen {
    enum Event {
        case didFetchBackup(Backup)
        case didFailToFetchBackup(HIPAPIError?)
    }
}
