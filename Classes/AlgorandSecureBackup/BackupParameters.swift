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

//   BackupParameters.swift

import Foundation

final class BackupParameters: ALGAPIModel {
    let deviceID: String?
    let providerName: String?
    let accounts: [AccountImportParameters]

    init() {
        deviceID = nil
        providerName = nil
        accounts = []
    }

    init(deviceID: String?, accounts: [AccountImportParameters]) {
        self.deviceID = deviceID
        self.providerName = "Pera Wallet"
        self.accounts = accounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deviceID = try container.decodeIfPresent(String.self, forKey: .deviceID)
        providerName = try container.decodeIfPresent(String.self, forKey: .providerName)
        let accountsApiModel = try container.decode([AccountImportParameters.APIModel].self, forKey: .accounts)
        accounts = accountsApiModel.map { .init($0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(deviceID, forKey: .deviceID)
        try container.encodeIfPresent(providerName, forKey: .providerName)
        try container.encode(accounts.map { $0.encode() }, forKey: .accounts)
    }
}

extension BackupParameters {
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case providerName = "provider_name"
        case accounts = "accounts"
    }
}
