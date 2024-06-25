// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingASAsRequestDetailList.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class IncomingASAsRequestDetailList:
    PaginatedList<IncomingASAsRequestDetailResult>,
    ALGEntityModel {    
    var address: String?
    var inboxAddress: String?
    
    convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrapMap(IncomingASAsRequestDetailResult.init)
        )
        self.address = apiModel.address
        self.inboxAddress = apiModel.inboxAddress
    }
    
    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results.map { $0.encode() }
        apiModel.address = address
        apiModel.inboxAddress = inboxAddress
        return apiModel
    }
}

extension IncomingASAsRequestDetailList {
    struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        var address: String?
        var inboxAddress: String?
        var count: Int?
        var next: URL?
        var previous: String?
        var results: [IncomingASAsRequestDetailResult.APIModel]?

        init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
            self.address = ""
            self.inboxAddress = ""
        }
        
        private enum CodingKeys:
               String,
               CodingKey {
            case count
            case next
            case previous
            case address
            case inboxAddress = "inbox_address"
            case results
        }
    }
}
