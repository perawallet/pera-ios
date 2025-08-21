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

//   SwapProviderV2List.swift

import Foundation

public final class SwapProviderV2List: ALGEntityModel {
    public let results: [SwapProviderV2]

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.results =  apiModel.results.unwrapMap(SwapProviderV2.init)
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.results = results.map { $0.encode() }
        return apiModel
    }
}

extension SwapProviderV2List {
    public struct APIModel: ALGAPIModel {
        var results: [SwapProviderV2.APIModel]?

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
