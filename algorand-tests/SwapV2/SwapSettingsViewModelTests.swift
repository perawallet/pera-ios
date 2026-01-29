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

//   SwapSettingsViewModelTests.swift

import Testing
@testable import pera_wallet_core
@testable import pera_staging

@Suite
struct SwapSettingsViewModelTests {
    
    @Test
    func test_initialization_setsSlippageText_andLocalSlippageSelected_custom() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: .custom(value: 0.123))

        // Then
        #expect(vm.slippageText == "12.3")
        #expect(vm.localSlippageSelected == .custom(value: 0.123))
    }
    
    @Test
    func test_initialization_setsSlippageText_andLocalSlippageSelected_c05() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: .c05)

        // Then
        #expect(vm.slippageText == "0.5")
        #expect(vm.localSlippageSelected == .c05)
    }
    
    @Test
    func test_initialization_setsSlippageText_default() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: .c1)

        // Then
        #expect(vm.slippageText == "1")
        #expect(vm.localSlippageSelected == .c1)
    }
    
    @Test
    func test_updateText_updatesPercentageText_andLocalPercentageSelected_knownValue() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)

        // When
        vm.updateText("5", for: .percentage)

        // Then
        #expect(vm.percentageText == "5")
        #expect(vm.localPercentageSelected == nil)
    }
    
    @Test
    func test_updateText_updatesPercentageText_andLocalPercentageSelected_unknownValue() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)

        // When
        vm.updateText("7", for: .percentage)

        // Then
        #expect(vm.percentageText == "7")
        #expect(vm.localPercentageSelected == nil)
    }

    @Test
    func test_updateText_updatesSlippageText_andLocalSlippageSelected_knownValue() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)

        // When
        vm.updateText("0.5", for: .slippage)

        // Then
        #expect(vm.slippageText == "0.5")
        #expect(vm.localSlippageSelected == .c05)
    }

    @Test
    func test_updateText_updatesSlippageText_andLocalSlippageSelected_customValue() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)

        // When
        vm.updateText("0.77", for: .slippage)

        // Then
        #expect(vm.slippageText == "0.77")
        #expect(vm.localSlippageSelected == .custom(value: 0.77))
    }

    @Test
    func test_updateText_slippage_invalidText_setsCustomZero() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)

        // When
        vm.updateText("abc", for: .slippage)

        // Then
        #expect(vm.slippageText == "")
    }

    @Test
    func test_applyChanges_setsLocalPercentageSelected_ifNilAndTextValid() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)
        vm.percentageText = "7"
        vm.localPercentageSelected = nil

        // When
        vm.applyChanges()

        // Then
        #expect(vm.localPercentageSelected == .custom(value: 0.07))
    }

    @Test
    func test_applyChanges_updatesUseLocalCurrency() {
        // Given
        let vm = SwapSettingsViewModel(slippageSelected: nil)
        vm.useLocalCurrency = true

        // When
        vm.applyChanges()

        // Then
        #expect(PeraUserDefaults.shouldUseLocalCurrencyInSwap == true)
    }
}
