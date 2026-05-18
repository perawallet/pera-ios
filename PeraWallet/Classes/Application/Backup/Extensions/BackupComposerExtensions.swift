// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BackupComposerExtensions.swift

extension AccountBackup: CustomStringConvertible {
    
    var description: String {
        
        switch self {
        case let .algo25(backup):
            desctiption(prefix: prefix, suffix: nil, backup: backup)
        case let .universalWallet(backup):
            desctiption(prefix: prefix, suffix: backup.wallet.seed.id, backup: backup)
        case let .watch(backup):
            desctiption(prefix: prefix, suffix: nil, backup: backup)
        case let .ledger(backup):
            desctiption(prefix: prefix, suffix: nil, backup: backup)
        case let .sharedAccount(backup):
            desctiption(prefix: prefix, suffix: nil, backup: backup)
        case let .invalid(backup):
            desctiption(prefix: prefix, suffix: nil, backup: backup)
        }
    }
    
    private var prefix: String {
        switch self {
        case .algo25:
            "Algo25"
        case .universalWallet:
            "Univer"
        case .watch:
            "Watch "
        case .ledger:
            "Ledger"
        case .sharedAccount:
            "Shared"
        case .invalid:
            "Inval "
        }
    }
    
    private func desctiption(prefix: String, suffix: String?, backup: AccountBackupable) -> String {
        let rekeyedText = backup.authAddress != nil ? "Rekeyed" : "Normal"
        let description = "[\(prefix)] \(backup.address) | \(rekeyedText) | \(backup.name)"
        guard let suffix else { return description }
        return description + " | \(suffix)"
    }
}

extension ContactBackup: CustomStringConvertible {
    
    var description: String {
        "[Contact] \(address) | \(name) | image: \(image == nil ? "No" : "Yes")"
    }
}

extension AuthBackup: CustomStringConvertible {

    var description: String {
        return "[Auth  ] pinCode: \(pinCode == nil ? "No" : "<Yes>")"
    }
}

extension PassKeyBackup: CustomStringConvertible {

    var description: String {
        "[PassKey] \(origin) | \(displayName) | \(address)"
    }
}
