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

//   IncomingASAsRequestDetailQuery.swift

import Foundation
import MagpieCore

struct IncomingASAsRequestDetailQuery: ObjectQuery, Equatable {
    var limit: String?
    var cursor: String?

    var hasMore: Bool {
        return cursor != nil
    }
    
    var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []
        
        if let cursor = cursor {
            params.append(.init(.cursor, cursor))
        }
        
        if let limit = limit {
            params.append(.init(.limit, limit))
        }

        return params
    }

    static func == (
        lhs: IncomingASAsRequestDetailQuery,
        rhs: IncomingASAsRequestDetailQuery
    ) -> Bool {
        return lhs.limit == rhs.limit &&
               lhs.cursor == rhs.cursor
    }
}
