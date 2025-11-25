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

//   NameService.swift

import Foundation

public final class NameServiceList:
    PaginatedList<NameServiceAPIModel>,
    ALGEntityModel {
    public convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrap(or: [])
        )
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results
        return apiModel
    }
}

extension NameServiceList {
    public struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        public var count: Int?
        public var next: URL?
        public var previous: String?
        public var results: [NameServiceAPIModel]?

        public init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

public final class NameServiceAPIModel:
    ALGAPIModel,
    Hashable {
    public let name: String
    public let address: String
    public let service: Service

    public var account: AccountHandle {
        let localAccount = AccountInformation(
            address: address,
            name: name,
            isWatchAccount: false,
            isBackedUp: true
        )
        let aRawAccount = Account(localAccount: localAccount)
        return AccountHandle(
            account: aRawAccount,
            status: .idle
        )
    }

    public init() {
        name = ""
        address = ""
        service = Service()
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case address
        case service
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }

    public static func == (
        lhs: NameServiceAPIModel,
        rhs: NameServiceAPIModel
    ) -> Bool {
        return lhs.address == rhs.address
    }
}

public final class Service: ALGAPIModel {
    public let name: String
    public let logo: String

    public init() {
        name = ""
        logo = ""
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case logo
    }
}
