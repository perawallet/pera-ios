// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   QRBackupInformations.swift

import Foundation

final class QRBackupInformations: ALGAPIModel {
    let identifier: String
    let modificationKey: String
    let encryptionKey: String
    let version: String
    let action: Action

    init() {
        identifier = ""
        modificationKey = ""
        encryptionKey = ""
        version = ""
        action = .none
    }
}

extension QRBackupInformations {
    enum CodingKeys: String, CodingKey {
        case identifier = "backupId"
        case modificationKey
        case encryptionKey
        case version
        case action
    }
}

extension QRBackupInformations {
    enum Action: String, ALGAPIModel {
        init?(rawValue: String) {
            switch rawValue {
            case "import":
                self = .import
            case "export":
                self = .export
            default:
                self = .none
            }
        }

        init() {
            self = .none
        }

        case `import`
        case export
        case none
    }
}
