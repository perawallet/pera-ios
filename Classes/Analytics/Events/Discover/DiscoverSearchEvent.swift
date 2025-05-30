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

//   DiscoverSearchEvent.swift

import Foundation
import MacaroonVendors

struct DiscoverSearchEvent: ALGAnalyticsEvent {
    let name: ALGAnalyticsEventName
    let metadata: ALGAnalyticsMetadata

    fileprivate init(assetID: AssetID, query: String?) {
        self.name = .discoverSearch

        guard let query else {
            self.metadata = [
                .assetID: String(assetID)
            ]
            return
        }

        self.metadata = [
            .assetID: String(assetID),
            .query: Self.regulate(query)
        ]
    }
}

extension AnalyticsEvent where Self == DiscoverSearchEvent {
    static func searchDiscover(assetID: AssetID, query: String?) -> Self {
        return DiscoverSearchEvent(assetID: assetID, query: query)
    }
}
