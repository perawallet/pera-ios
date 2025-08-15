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

//   UpdateSwapQuoteDraft.swift

import MagpieCore

public struct UpdateSwapQuoteDraft: JSONObjectBody {
    public let id: Int64
    public let exception: String
    
    public init(id: Int64, exception: String) {
        self.id = id
        self.exception = exception
    }

    public var bodyParams: [APIBodyParam] {
        let params: [APIBodyParam] = [
            .init(.exceptionText, exception)
        ]
        return params
    }
}
