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

//   AssetToogleStatus.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class AssetToogleStatus: ALGEntityModel {
    public let isEnabled: Bool
    
    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.isEnabled = apiModel.is_enabled
    }
    
    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.is_enabled = isEnabled
        return apiModel
    }
}

extension AssetToogleStatus {
    public struct APIModel: ALGAPIModel {
        var is_enabled: Bool

        public init() {
            self.is_enabled = false
        }
    }
}
