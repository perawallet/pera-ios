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

//   TransactionsV2Query.swift

import MagpieCore

struct TransactionsV2Query: ObjectQuery {
    let ordering: String?
    let cursor: String?
    let limit: Int?
    let assetId: String?
    let from: String?
    let to: String?
    
    var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []
        if let ordering {
            params.append(APIQueryParam(.ordering, ordering))
        }
        
        if let cursor {
            params.append(APIQueryParam(.cursor, cursor))
        }
        
        if let limit {
            params.append(APIQueryParam(.limit, limit))
        }
        
        if let assetId {
            params.append(APIQueryParam(.asset, assetId))
        }
        
        if let from {
            params.append(APIQueryParam(.afterTime, from))
        }
        
        if let to {
            params.append(APIQueryParam(.beforeTime, to))
        }
        
        return params
    }
}
