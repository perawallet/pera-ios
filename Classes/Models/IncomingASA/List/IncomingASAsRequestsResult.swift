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

//   IncomingASAsRequestsResult.swift

import Foundation
import MagpieCore

final class IncomingASAsRequestsResult: ALGEntityModel {
    var address: String?
    var inboxAddress: String?
    var requestCount: Int?
    
    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.address = apiModel.address
        self.inboxAddress = apiModel.inboxAddress
        self.requestCount = apiModel.requestCount
    }
    
    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = address
        apiModel.inboxAddress = inboxAddress
        apiModel.requestCount = requestCount
        return apiModel
    }
}

extension IncomingASAsRequestsResult {
    struct APIModel: ALGAPIModel {
        var address: String?
        var inboxAddress: String?
        var requestCount: Int?
        
        init() {
            self.address = nil
            self.inboxAddress = nil
            self.requestCount = nil
        }
        
        private enum CodingKeys:
               String,
               CodingKey {
            case address
            case inboxAddress = "inbox_address"
            case requestCount = "request_count"
        }
    }
}
