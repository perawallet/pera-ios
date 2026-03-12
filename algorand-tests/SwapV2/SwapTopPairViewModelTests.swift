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

//   SwapTopPairViewModelTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapTopPairViewModelTests {
    
    @Test
    func test_isListEmpty_whenListIsEmpty() {
        // Given
        let vm = SwapTopPairViewModel(swapTopPairsList: [])

        // Then
        #expect(vm.isListEmpty == true)
    }
    
    @Test
    func test_isListEmpty_whenListIsNotEmpty() {
        // Given
        let pair = makeSwapTopPair(assetA: makeSwapAsset(id: 123, name: "MockAssetA"), assetB: makeSwapAsset(id: 456, name: "MockAssetB"))
        let vm = SwapTopPairViewModel(swapTopPairsList: [pair])

        // Then
        #expect(vm.isListEmpty == false)
    }
    
    @Test
    func test_swapTopPairsArray_returnsUpTo5PairsWithOffset() {
        // Given
        let pairs = (1...6).map { i in
            makeSwapTopPair(assetA: makeSwapAsset(id: 123+i, name: "MockAssetA_\(i)"), assetB: makeSwapAsset(id: 456+i, name: "MockAssetB_\(i)"))
        }
        let vm = SwapTopPairViewModel(swapTopPairsList: pairs)

        // When
        let array = vm.swapTopPairsArray

        // Then
        #expect(array.count == 5)
    }
    
    @Test
    func test_indexTitleFor_returnsCorrectFormat() {
        // Given
        let vm = SwapTopPairViewModel(swapTopPairsList: [])

        // When
        let title = vm.indexTitleFor(index: 2)

        // Then
        #expect(title == "3.")
    }
    
    @Test
    func test_rowTitleFor_formatsCorrectly() {
        // Given
        let pair = makeSwapTopPair(assetA: makeSwapAsset(id: 123, name: "MockAssetA"), assetB: makeSwapAsset(id: 456, name: "MockAssetB"))
        let vm = SwapTopPairViewModel(swapTopPairsList: [pair])

        // When
        let rowTitle = vm.rowTitleFor(index: 0)

        // Then
        #expect(rowTitle.contains("MockAssetA"))
        #expect(rowTitle.contains("MockAssetB"))
    }
    
    // MARK: - Helpers

    private func makeSwapTopPair(
        assetA: SwapAsset,
        assetB: SwapAsset
    ) -> SwapTopPair {
        var apiModel = SwapTopPair.APIModel()
        apiModel.assetA = assetA
        apiModel.assetB = assetB
        return SwapTopPair(apiModel)
    }
    
    private func makeSwapAsset(id: Int64, name: String) -> SwapAsset {
        var apiModel = SwapAsset.APIModel()
        apiModel.assetID = id
        apiModel.name = name
        return SwapAsset(apiModel)
    }
}
