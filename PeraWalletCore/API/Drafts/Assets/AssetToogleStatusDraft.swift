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

//   AssetToogleStatusDraft.swift

import MagpieCore

public struct AssetToogleStatusDraft: JSONObjectBody {
    var deviceId: Int64
    var enabled: Bool
    
    public var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.deviceId, deviceId))
        params.append(.init(.enabled, enabled))
        
        return params
    }
    
    public init(deviceId: Int64, enabled: Bool) {
        self.deviceId = deviceId
        self.enabled = enabled
    }
}
