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

//   SwapHistoryViewModel.swift

import SwiftUI
import pera_wallet_core

final class SwapHistoryViewModel: ObservableObject {
    @Published private(set) var swapHistoryList: [SwapHistory]?
    @Published private(set) var uniqueSwapHistoryList: [SwapHistory]?
    @Published private(set) var shouldShowSeeAllButton: Bool = false
    
    init(swapHistoryList: [SwapHistory]?) {
        self.swapHistoryList = swapHistoryList
        self.uniqueSwapHistoryList = listWithoutDuplicates(from: swapHistoryList)
        self.shouldShowSeeAllButton = swapHistoryList?.isNonEmpty ?? false
    }
    
    private func listWithoutDuplicates(from list: [SwapHistory]?) -> [SwapHistory]? {
        guard let list else { return nil }
        return list.reduce(into: [SwapHistory]()) { result, item in
            if !result.contains(where: {
                $0.assetIn.assetID == item.assetIn.assetID &&
                $0.assetOut.assetID == item.assetOut.assetID
            }) {
                result.append(item)
            }
        }
    }
}
