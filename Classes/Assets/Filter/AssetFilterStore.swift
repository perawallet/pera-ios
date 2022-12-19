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

//   AssetFilterStore.swift

import Foundation

struct AssetFilterStore {
    private let cache = Cache()

    var hideAssetsWithNoBalanceInAssetList: Bool { 
        get { cache.hideAssetsWithNoBalanceInAssetList }
        set { cache.hideAssetsWithNoBalanceInAssetList = newValue }
    }

    var displayCollectibleAssetsInAssetList: Bool {
        get { cache.displayCollectibleAssetsInAssetList }
        set { cache.displayCollectibleAssetsInAssetList = newValue }
    }

    var displayOptedInCollectibleAssetsInAssetList: Bool {
        get { cache.displayOptedInCollectibleAssetsInAssetList }
        set { cache.displayOptedInCollectibleAssetsInAssetList = newValue  }
    }
}

extension AssetFilterStore {
    private final class Cache: Storable {
        typealias Object = Any

        var hideAssetsWithNoBalanceInAssetList: Bool {
            get {
                let intValue = userDefaults.integer(forKey: hideAssetsWithNoBalanceInAssetListKey)
                return intValue != 0
            }
            set {
                let intValue = newValue ? 1 : 0
                userDefaults.set(intValue, forKey: hideAssetsWithNoBalanceInAssetListKey)
            }
        }

        var displayCollectibleAssetsInAssetList: Bool {
            get {
                return userDefaults.bool(forKey: displayCollectibleAssetsInAssetListKey)
            }
            set {
                userDefaults.set(newValue, forKey: displayCollectibleAssetsInAssetListKey)
            }
        }

        var displayOptedInCollectibleAssetsInAssetList: Bool {
            get {
                return userDefaults.bool(forKey: displayOptedInCollectibleAssetsInAssetListKey)
            }
            set {
                userDefaults.set(newValue, forKey: displayOptedInCollectibleAssetsInAssetListKey)
            }
        }

        private let hideAssetsWithNoBalanceInAssetListKey = "cache.key.assetsFilteringOption"
        private let displayCollectibleAssetsInAssetListKey = "cache.key.displayCollectibleAssetsInAssetList"
        private let displayOptedInCollectibleAssetsInAssetListKey = "cache.key.displayOptedInCollectibleAssetsInAssetList"
    }
}
