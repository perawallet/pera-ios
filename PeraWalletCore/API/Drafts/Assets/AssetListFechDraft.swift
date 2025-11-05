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

//   AssetListFechDraft.swift

import MagpieCore

public struct AssetListFechDraft: JSONObjectBody {
    let ids: [AssetID]
    var includeDeleted: Bool? = nil
    var deviceId: String?
    
    public var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.assetIDs, ids))
        
        if let includeDeleted {
            params.append(.init(.includeDeleted, includeDeleted))
        }
        
        if let deviceId {
            params.append(.init(.deviceId, deviceId))
        }
        
        return params
    }
    
    public init(ids: [AssetID], includeDeleted: Bool? = nil, deviceId: String? = nil) {
        self.ids = ids
        self.includeDeleted = includeDeleted
        self.deviceId = deviceId
    }
}
