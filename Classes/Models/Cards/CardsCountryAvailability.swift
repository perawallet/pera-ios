// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CardsCountryAvailability.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class CardsCountryAvailability: ALGEntityModel {
    let isWaitlisted: Bool

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.isWaitlisted = apiModel.isWaitlisted
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.isWaitlisted = isWaitlisted
        return apiModel
    }
}

extension CardsCountryAvailability {
    struct APIModel: ALGAPIModel {
        var isWaitlisted: Bool

        init() {
            self.isWaitlisted = false
        }
        
        private enum CodingKeys: String, CodingKey {
            case isWaitlisted = "is_waitlisted"
        }
    }
}
