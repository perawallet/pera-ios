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
//   ApplicationLocalState.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class ApplicationLocalState: ALGResponseModel {
    var debugData: Data?
    
    var closedAtRound: UInt64?
    var isDeleted: Bool?
    var id: Int64?
    var optedInAtRound: UInt64?
    var schema: ApplicationStateSchema?

    init(_ apiModel: APIModel = APIModel()) {
        self.closedAtRound = apiModel.closedOutAtRound
        self.isDeleted = apiModel.deleted
        self.id = apiModel.id
        self.optedInAtRound = apiModel.optedInAtRound
        self.schema = apiModel.schema.unwrap(ApplicationStateSchema.init)
    }
}

extension ApplicationLocalState {
    struct APIModel: ALGAPIModel {
        let closedOutAtRound: UInt64?
        let deleted: Bool?
        let id: Int64?
        let optedInAtRound: UInt64?
        let schema: ApplicationStateSchema.APIModel?

        init() {
            self.closedOutAtRound = nil
            self.deleted = nil
            self.id = nil
            self.optedInAtRound = nil
            self.schema = nil
        }
    }
}
