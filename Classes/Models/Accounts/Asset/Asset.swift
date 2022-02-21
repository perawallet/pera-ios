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

//   Asset.swift

import Foundation

/// Mimics ALGAsset in general so that it can be passed to different asset types as base.
protocol Asset {
    var id: AssetID { get }
    var amount: UInt64 { get }
    var isFrozen: Bool? { get }
    var isDeleted: Bool? { get }
    var creator: AssetCreator? { get }

    init(asset: ALGAsset, decoration: AssetDecoration)
}
