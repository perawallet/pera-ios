// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapHistoryViewModelTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapHistoryViewModelTests {
    
    @Test
    func test_uniqueSwapHistoryList_removesDuplicates() {
        // Given
        let assetA = makeSwapAsset(id: 1, name: "MockAsset1")
        let assetB = makeSwapAsset(id: 2, name: "MockAsset2")
        
        let history1 = makeSwapHistory(assetIn: assetA, assetOut: assetB)
        let history2 = makeSwapHistory(assetIn: assetA, assetOut: assetB) // duplicate
        let history3 = makeSwapHistory(assetIn: assetB, assetOut: assetA)
        
        let swapHistoryList = [history1, history2, history3]
        
        // When
        let viewModel = SwapHistoryViewModel(swapHistoryList: swapHistoryList)
        let result = viewModel.uniqueSwapHistoryList
        
        // Then
        #expect(viewModel.swapHistoryList?.count == 3)
        #expect(result?.count == 2)
    }
    
    @Test
    func test_uniqueSwapHistoryList_nilIfInputIsNil() {
        // Given
        let swapHistoryList: [SwapHistory]? = nil
        
        // When
        let viewModel = SwapHistoryViewModel(swapHistoryList: swapHistoryList)
        let result = viewModel.uniqueSwapHistoryList
        
        // Then
        #expect(result == nil)
    }
    
    @Test
    func test_shouldShowSeeAllButton_trueWhenListIsNotEmpty() {
        // Given
        let assetA = makeSwapAsset(id: 1, name: "MockAsset1")
        let assetB = makeSwapAsset(id: 2, name: "MockAsset2")
        
        let history = makeSwapHistory(assetIn: assetA, assetOut: assetB)
        
        // When
        let viewModel = SwapHistoryViewModel(swapHistoryList: [history])
        let result = viewModel.shouldShowSeeAllButton
        
        // Then
        #expect(result == true)
    }
    
    @Test
    func test_shouldShowSeeAllButton_falseWhenListIsEmpty() {
        // Given
        let swapHistoryList: [SwapHistory] = []
        
        // When
        let viewModel = SwapHistoryViewModel(swapHistoryList: swapHistoryList)
        let result = viewModel.shouldShowSeeAllButton
        
        // Then
        #expect(result == false)
    }
    
    // MARK: - Helpers

    private func makeSwapHistory(
        assetIn: SwapAsset,
        assetOut: SwapAsset
    ) -> SwapHistory {
        var apiModel = SwapHistory.APIModel()
        apiModel.assetIn = assetIn
        apiModel.assetOut = assetOut
        return SwapHistory(apiModel)
    }
    
    private func makeSwapAsset(id: Int64, name: String) -> SwapAsset {
        var apiModel = SwapAsset.APIModel()
        apiModel.assetID = id
        apiModel.name = name
        return SwapAsset(apiModel)
    }
}
