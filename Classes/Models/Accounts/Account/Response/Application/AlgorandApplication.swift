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
//   AlgorandApplication.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AlgorandApplication: ALGResponseModel {
    var debugData: Data?
    
    var createdAtRound: UInt64?
    var isDeleted: Bool?
    var id: Int64?
    var deletedAtRound: UInt64?

    init(_ apiModel: APIModel = APIModel()) {
        self.createdAtRound = apiModel.createdAtRound
        self.isDeleted = apiModel.deleted
        self.id = apiModel.id
        self.deletedAtRound = apiModel.deletedAtRound
    }
}

extension AlgorandApplication {
    struct APIModel: ALGAPIModel {
        let createdAtRound: UInt64?
        let deleted: Bool?
        let id: Int64?
        let deletedAtRound: UInt64?

        init() {
            self.createdAtRound = nil
            self.deleted = nil
            self.id = nil
            self.deletedAtRound = nil
        }
    }
}
