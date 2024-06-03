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

//   IncommingASAsRequestDetail.swift

import Foundation
import MagpieCore
import MacaroonUtils

// MARK: - IncommingASAsRequestDetailListResult
final class IncommingASAsRequestDetailResult: ALGEntityModel {
    var totalAmount: Int?
    var asset: AssetDecoration?
    var senders: Senders?
    
    // Initializer from APIModel
    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.totalAmount = apiModel.totalAmount
        self.asset = apiModel.asset.unwrap(AssetDecoration.init)
        self.senders = apiModel.senders.unwrap(Senders.init)
    }
    
    // Encode function to convert to APIModel
    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.totalAmount = totalAmount
        apiModel.asset = asset?.encode()
        apiModel.senders = senders?.encode()
        return apiModel
    }
}

extension IncommingASAsRequestDetailResult {
    struct APIModel: ALGAPIModel {
        var totalAmount: Int?
        var asset: AssetDecoration.APIModel?
        var senders: Senders.APIModel?

        init() {
            self.totalAmount = 0
            self.asset = .init()
            self.senders = .init()
        }

        private enum CodingKeys: String, CodingKey {
            case totalAmount = "total_amount"
            case asset
            case senders
        }
    }
}

// MARK: - Senders
final class Senders: ALGEntityModel {
    var count: Int?
    var results: [SendersResult]?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.count = apiModel.count
        self.results = apiModel.results?.map(SendersResult.init)
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = self.count
        apiModel.results = self.results?.map { $0.encode() }
        return apiModel
    }
}

extension Senders {
    struct APIModel: ALGAPIModel {
        var count: Int?
        var results: [SendersResult.APIModel]?

        init() {
            self.count = 0
            self.results = []
        }

        private enum CodingKeys: String, CodingKey {
            case count
            case results
        }
    }
}

// MARK: - SendersResult
final class SendersResult: ALGEntityModel {
    var sender: Sender?
    var amount: Int?
    
    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.sender = apiModel.sender.map(Sender.init)
        self.amount = apiModel.amount
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.sender = self.sender?.encode()
        apiModel.amount = self.amount
        return apiModel
    }
}

extension SendersResult {
    struct APIModel: ALGAPIModel {
        var sender: Sender.APIModel?
        var amount: Int?

        init() {
            self.sender = .init()
            self.amount = 0
        }

        private enum CodingKeys: String, CodingKey {
            case sender
            case amount
        }
    }
}

// MARK: - Sender
final class Sender: ALGEntityModel {
    var address: String?
    var name: String?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.address = apiModel.address
        self.name = apiModel.name
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.address = self.address
        apiModel.name = self.name
        return apiModel
    }
}

extension Sender {
    struct APIModel: ALGAPIModel {
        var address: String?
        var name: String?

        init() {
            self.address = ""
            self.name = ""
        }

        private enum CodingKeys: String, CodingKey {
            case address
            case name
        }
    }
}
