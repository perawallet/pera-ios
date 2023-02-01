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
    let address: String
    let name: String?
    let accountType: ImportedAccountType
    let privateKey: Data?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        accountType = try container.decode(ImportedAccountType.self, forKey: .accountType)
        privateKey = try? container.decodeIfPresent(Data.self, forKey: .privateKey)
    }
}

extension AccountImportParameters {
    enum CodingKeys: String, CodingKey {
        case address
        case name
        case accountType = "account_type"
        case privateKey = "private_key"
    }
}

enum ImportedAccountType:
    ALGAPIModel,
    RawRepresentable,
    CaseIterable,
    Hashable {
    case single
    case unsupported(String)

    var rawValue: String {
        switch self {
        case .single: return "single"
        case .unsupported(let someType): return someType
        }
    }

    var peraAccountType: AccountType {
        switch self {
        case .single:
            return .standard
        case .unsupported:
            return .standard
        }
    }

    static var allCases: [ImportedAccountType] = [
        .single
    ]

    init() {
        self = .unsupported("Unsupported")
    }

    init?(rawValue: String) {
        let someType = Self.allCases.first(matching: (\.rawValue, rawValue))
        self = someType ?? .unsupported(rawValue)
    }

    init(peraType: AccountType) {
        switch peraType {
        case .standard:
            self = .single
        default:
            self = .unsupported(peraType.rawValue)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    static func == (
        lhs: ImportedAccountType,
        rhs: ImportedAccountType
    ) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
