// Copyright 2022-2025 Pera Wallet, LDA

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
    let accountType: AccountType
    let privateKey: Data?
    
    init() {
        address = ""
        name = nil
        accountType = .unsupported("unsupported")
        privateKey = nil
    }

    init(account: Account, accountType: AccountType, privateKey: Data?) {
        self.address = account.address
        self.name = account.name
        self.accountType = accountType
        self.privateKey = privateKey
    }

    init(accountImportParameters: AccountImportParameters, privateKey: Data?) {
        self.address = accountImportParameters.address
        self.name = accountImportParameters.name
        self.accountType = accountImportParameters.accountType
        self.privateKey = privateKey
    }

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        address = apiModel.address ?? ""
        name = apiModel.name
        accountType = apiModel.accountType ?? .unsupported("Unsupported")
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
    enum AccountType:
        ALGAPIModel,
        RawRepresentable,
        CaseIterable,
        Hashable {
        case single
        case unsupported(String)
        case watch
        typealias RawAccountType = AccountAuthorization

        var rawValue: String {
            switch self {
            case .single: return "single"
            case .unsupported(let someType): return someType
            case .watch: return "watch"
            }
        }

        var rawAccountType: RawAccountType {
            switch self {
            case .single: return .standard
            case .unsupported: return .standard
            case .watch: return .watch
            }
        }

        static var allCases: [AccountType] = [
            .single
        ]

        init() {
            self = .unsupported("Unsupported")
        }

        init?(rawValue: String) {
            if let rawAccountType = RawAccountType(rawValue: rawValue) {
                self.init(rawAccountType: rawAccountType)
            } else {
                self.init(stringRawValue: rawValue)
            }
        }

        private init(stringRawValue: String) {
            switch stringRawValue {
            case Self.single.rawValue:
                self = .single
            default:
                self = .unsupported(stringRawValue)
            }
        }

        init(rawAccountType: RawAccountType) {
            switch rawAccountType {
            case .standard: self = .single
            default: self = .unsupported(rawAccountType.rawValue)
            }
        }

        init(from decoder: Decoder) throws {
            let singleValueContainer = try decoder.singleValueContainer()
            let rawValue = try singleValueContainer.decode(String.self)

            self.init(stringRawValue: rawValue)
        }
    }

    func isImportable(using algorandSDK: AlgorandSDK) -> Bool {
        if accountType == .watch {
            return algorandSDK.isValidAddress(self.address)
        }
        
        if case .unsupported = accountType {
            return false
        }
        
        guard accountType == .single, let privateKey = privateKey else {
            return false
        }

        var error: NSError?
        let address = algorandSDK.addressFrom(privateKey, error: &error)
        return address == self.address && algorandSDK.isValidAddress(self.address)
    }
}

extension AccountImportParameters {
    struct APIModel: ALGAPIModel {
        var address: String?
        var name: String?
        var accountType: AccountImportParameters.AccountType?
        var privateKey: Data?

        init() {
            self.address = nil
            self.name = nil
            self.accountType = nil
            self.privateKey = nil
        }
    }
}

extension AccountImportParameters.APIModel {
    private enum CodingKeys: String, CodingKey {
        case address
        case name
        case accountType = "account_type"
        case privateKey = "private_key"
    }
}
