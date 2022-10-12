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

//
//  Notification.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class NotificationMessage: ALGEntityModel {
    let id: Int
    let accountAddress: String?
    let url: URL?
    let date: Date?
    let message: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.id = apiModel.id ?? 0
        self.accountAddress = apiModel.accountAddress
        self.url = apiModel.url
        /// <todo>
        /// Without format string ???
        self.date = apiModel.creationDatetime?.toDate()?.date
        self.message = apiModel.message
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.id = id
        apiModel.accountAddress = accountAddress
        apiModel.url = url
        apiModel.creationDatetime = date?.toString(.standard)
        apiModel.message = message
        return apiModel
    }
}

extension NotificationMessage {
    struct APIModel: ALGAPIModel {
        var id: Int?
        var accountAddress: String?
        var url: URL?
        var creationDatetime: String?
        var message: String?

        init() {
            self.id = nil
            self.accountAddress = nil
            self.url = nil
            self.creationDatetime = nil
            self.message = nil
        }

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case accountAddress = "account_address"
            case url = "url"
            case creationDatetime = "creation_datetime"
            case message = "message"
        }
    }
}

final class NotificationMessageList:
    PaginatedList<NotificationMessage>,
    ALGEntityModel {
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(NotificationMessage.init)
        )
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results.map { $0.encode() }
        return apiModel
    }
}

extension NotificationMessageList {
    struct APIModel: ALGAPIModel, PaginationComponents {
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [NotificationMessage.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

extension NotificationMessage: Hashable {
    static func == (lhs: NotificationMessage, rhs: NotificationMessage) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
