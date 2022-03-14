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

//   CollectibleExternalSource.swift

import Foundation
import MacaroonUIKit

enum CollectibleExternalSource {
    case algoExplorer
    case nftExplorer

    var image: Image? {
        switch self {
        case .algoExplorer:
            return img("icon-algo-explorer")
        case .nftExplorer:
            return img("icon-nft-explorer")
        }
    }

    var title: EditText? {
        switch self {
        case .algoExplorer:
            return .string("collectible-detail-algo-explorer".localized)
        case .nftExplorer:
            return .string("collectible-detail-nft-explorer".localized)
        }
    }
}
