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

//   AccountImportParameters.swift

import Foundation
import MacaroonUtils

struct AccountImportParameters: JSONModel {
    let name: String
    let privateKey: Data

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let privateKeyString = try container.decode(String.self, forKey: .privateKey)
        let privateKeyByteArray = privateKeyString.convertToByteArray(using: ",")
        privateKey = Data(bytes: privateKeyByteArray)
    }
}

extension AccountImportParameters {
    enum CodingKeys: String, CodingKey {
        case name
        case privateKey = "private_key"
    }
}
