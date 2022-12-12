// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleFilterStore.swift

import Foundation

struct CollectibleFilterStore {
    private let cache = Cache()

    var displayOptedInCollectibleAssets: Bool {
        get { cache.displayOptedInCollectibleAssets }
        set { cache.displayOptedInCollectibleAssets = newValue }
    }

    var displayWatchAccountCollectibleAssets: Bool {
        get { cache.displayWatchAccountCollectibleAssets }
        set { cache.displayWatchAccountCollectibleAssets = newValue  }
    }
}

extension CollectibleFilterStore {
    private final class Cache: Storable {
        typealias Object = Any

        var displayOptedInCollectibleAssets: Bool {
            get {
                let intValue = userDefaults.integer(forKey: displayOptedInCollectibleAssetsKey)
                return intValue != 0
            }
            set {
                let intValue = newValue ? 1 : 0
                userDefaults.set(intValue, forKey: displayOptedInCollectibleAssetsKey)
            }
        }

        var displayWatchAccountCollectibleAssets: Bool {
            get {
                if !userDefaults.valueExists(forKey: displayWatchAccountCollectibleAssetsKey)  {
                    userDefaults.set(true, forKey: displayWatchAccountCollectibleAssetsKey)
                    return true
                }

                return userDefaults.bool(forKey: displayWatchAccountCollectibleAssetsKey)
            }
            set {
                userDefaults.set(newValue, forKey: displayWatchAccountCollectibleAssetsKey)
            }
        }

        private let displayOptedInCollectibleAssetsKey = "cache.key.collectibleListFilter"
        private let displayWatchAccountCollectibleAssetsKey = "cache.key.displayWatchAccountCollectibleAssets"
    }
}
