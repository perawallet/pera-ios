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

struct AccountImportParameters: ALGEntityModel {
    let address: String
    let name: String?
    let accountType: ImportedAccountType
    let privateKey: Data?

    init() {
        address = ""
        name = nil
        accountType = .unsupported("unsupported")
        privateKey = nil
    }

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        address = apiModel.address ?? ""
        name = apiModel.name
        accountType = apiModel.accountType ?? .unsupported("unsupported")
        privateKey = apiModel.privateKey
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = address
        apiModel.name = name
        apiModel.accountType = accountType
        apiModel.privateKey = privateKey
        return apiModel
    }
}

extension AccountImportParameters {
    struct APIModel: ALGAPIModel {
        var address: String?
        var name: String?
        var accountType: ImportedAccountType?
        var privateKey: Data?

        init() {
            self.address = nil
            self.name = nil
            self.accountType = nil
            self.privateKey = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
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

    var rawAccountType: AccountType {
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
        switch rawValue {
            case AccountType.standard.rawValue: self = .single
            default: self = .unsupported(rawValue)
        }
    }

    init(rawAccountType: AccountType) {
        switch rawAccountType {
        case .standard:
            self = .single
        default:
            self = .unsupported(rawAccountType.rawValue)
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension RawRepresentable where Self: Hashable, Self.RawValue: Hashable {
    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
