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

//   AccountSortingAlgorithm.swift

import Foundation

public protocol AccountSortingAlgorithm {
    var id: String { get }
    var name: String { get }
    /// <note>
    /// If it is true, then there is no predefined formula for sorting.
    var isCustom: Bool { get }

    func getFormula(
        account: AccountHandle,
        otherAccount: AccountHandle
    ) -> Bool
}

public protocol AssetFilterAlgorithm {
    func getFormula(asset: Asset) -> Bool
}

public struct AssetZeroBalanceFilterAlgorithm: AssetFilterAlgorithm {
    public init() {}
    
    public func getFormula(
        asset: Asset
    ) -> Bool {
        return asset.amount > 0
    }
}

public struct AssetExcludeFilterAlgorithm: AssetFilterAlgorithm {
    private let excludedList: [Asset]

    public init(excludedList: [Asset]) {
        self.excludedList = excludedList
    }

    public func getFormula(
        asset: Asset
    ) -> Bool {
        return excludedList.contains { $0.id != asset.id }
    }
}
