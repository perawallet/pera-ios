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

//   SwapTopPairsList.swift

import Foundation

public final class SwapTopPairsList: ALGEntityModel {
    public let results: [SwapTopPair]

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.results = apiModel.results.unwrapMap(SwapTopPair.init)
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.results = results.map { $0.encode() }
        return apiModel
    }
}

extension SwapTopPairsList {
    public struct APIModel: ALGAPIModel {
        var results: [SwapTopPair.APIModel]?

        public init() {
            self.results = []
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case results
        }
    }
}
