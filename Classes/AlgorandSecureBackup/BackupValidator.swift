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

//   BackupValidator.swift

import Foundation

final class BackupValidator {
    private let supportedVersion: String = "1.0"

    func validate(invalidatedString: String?) -> BackupValidation {
        guard let invalidatedString, !invalidatedString.isEmptyOrBlank else {
            return .failure(.emptySource)
        }

        guard let data = Data(base64Encoded: invalidatedString) else {
            return .failure(.wrongFormat)
        }

        guard let secureBackup = try? SecureBackup.decoded(data) else {
            return .failure(.jsonSerialization)
        }

        guard secureBackup.version == supportedVersion else {
            return .failure(.unsupportedVersion)
        }

        guard !secureBackup.suite.isNilOrEmpty else {
            return .failure(.cipherSuiteUnknown)
        }

        guard secureBackup.cipherText != nil else {
            return .failure(.cipherSuiteInvalid)
        }

        return .success(secureBackup)
    }
}

enum BackupValidation {
    case success(SecureBackup)
    case failure(BackupValidationError)
}

enum BackupValidationError: Error {
    case emptySource
    case wrongFormat // It should be base 64
    case jsonSerialization
    case unsupportedVersion
    case cipherSuiteUnknown
    case cipherSuiteInvalid
    case unauthorized
}
