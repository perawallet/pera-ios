// Copyright 2019 Algorand, Inc.

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

final class NotificationMessage: ALGResponseModel {
    var debugData: Data?

    let id: Int
    let account: Int?
    let notificationType: NotificationType?
    let date: Date?
    let message: String?
    let detail: NotificationDetail?

    init(_ apiModel: APIModel = APIModel()) {
        self.id = apiModel.id
        self.account = apiModel.account
        self.notificationType = apiModel.type
        self.date = apiModel.creationDatetime?.toDate()?.date
        self.message = apiModel.message
        self.detail = apiModel.metadata.unwrap(NotificationDetail.init)
    }
}

extension NotificationMessage {
    struct APIModel: ALGAPIModel {
        let id: Int
        let account: Int?
        let type: NotificationType?
        let creationDatetime: String?
        let message: String?
        let metadata: NotificationDetail.APIModel?

        init() {
            self.id = 0
            self.account = nil
            self.type = nil
            self.creationDatetime = nil
            self.message = nil
            self.metadata = nil
        }
    }
}

final class NotificationMessageList: PaginatedList<NotificationMessage>, ALGResponseModel {
    var debugData: Data?

    convenience init(_ apiModel: APIModel = APIModel()){
        self.init(pagination: apiModel, results: apiModel.results.unwrapMap(NotificationMessage.init))
    }
}

extension NotificationMessageList {
    struct APIModel: ALGAPIModel, PaginationComponents {
        let count: Int?
        let next: URL?
        let previous: String?
        let results: [NotificationMessage.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}
