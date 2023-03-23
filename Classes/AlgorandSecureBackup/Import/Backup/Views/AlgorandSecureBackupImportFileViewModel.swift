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

//   AlgorandSecureBackupImportFileViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupImportFileViewModel: ViewModel {
    var image: ImageProvider?
    var imageStyle: ImageStyle?
    var title: TextProvider?
    var subtitle: TextProvider?
    var isActionVisible: Bool = false

    init(state: State) {
        bindImage(for: state)
        bindTitle(for: state)
        bindSubtitle(for: state)
        bindActionVisibility(for: state)
    }
}

extension AlgorandSecureBackupImportFileViewModel {
    private mutating func bindImage(for state: State) {
        switch state {
        case .empty:
            image = "icon-share-24".templateImage
            imageStyle = [
                .tintColor(Colors.Text.main)
            ]
        case .uploaded:
            image = "icon-check".templateImage
            imageStyle = [
                .tintColor(Colors.Helpers.positive)
            ]
        case .uploadFailed:
            image = "icon-error-close".templateImage
            imageStyle = [
                .tintColor(Colors.Helpers.negative)
            ]
        }
    }

    private mutating func bindTitle(for state: State) {
        switch state {
        case .empty:
            title = "algorand-secure-backup-import-backup-title".localized.bodyMedium(alignment: .center)
        case .uploaded:
            title = "algorand-secure-backup-import-backup-upload-successful-title".localized.bodyMedium(alignment: .center)
        case .uploadFailed(let error):
            let errorTitle: String
            switch error {
            case .unsupported:
                errorTitle = "algorand-secure-backup-import-backup-upload-failed-subtitle".localized
            case .invalid:
                errorTitle = "algorand-secure-backup-import-backup-upload-failed-invalid-subtitle".localized
            case .other(let internalError):
                errorTitle = internalError.localizedDescription
            }
            title = errorTitle.bodyMedium(alignment: .center)
        }
    }

    private mutating func bindSubtitle(for state: State) {
        switch state {
        case .empty:
            subtitle = nil
        case .uploaded(let uploadedFile):
            subtitle = uploadedFile.filePath?.footnoteRegular(alignment: .center)
        case .uploadFailed:
            subtitle = nil
        }
    }

    private mutating func bindActionVisibility(for state: State) {
        switch state {
        case .empty:
            isActionVisible = false
        case .uploaded, .uploadFailed:
            isActionVisible = true
        }
    }
}

extension AlgorandSecureBackupImportFileViewModel {
    enum State {
        case empty
        case uploaded(AlgorandSecureBackupFile)
        case uploadFailed(AlgorandSecureBackupImportBackupScreen.FileError)
    }
}

struct AlgorandSecureBackupFile {
    let data: Data?
    let filePath: String?

    init(url: URL) {
        do {
            data = try Data(contentsOf: url)
            filePath = url.lastPathComponent
        } catch {
            data = nil
            filePath = nil
        }
    }

    init(data: Data) {
        self.data = data
        let dateString = Date().toFormat(.fileDate)
        self.filePath = "\(dateString)_backup.txt"
    }
}
