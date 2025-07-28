// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapView.swift

import SwiftUI

struct SwapView: View {
    @State private var assetDefaultIcon = Image("icon-algo-circle")
    @State private var assetDefaultText = String(localized: "title-algo")
    @State private var accountDefaultIcon = Image("icon-standard-account")
    @State private var accountDefaultText = String(localized: "title-main-account")
    
    var body: some View {
        AssetSwapButton(icon: $assetDefaultIcon, text: $assetDefaultText) {
            print("AssetSwapButton")
        }
        AccountSelectionButton(icon: $accountDefaultIcon, text: $accountDefaultText) {
            print("AccountSelectionButton")
        }
        SettingsSwapButton {
            print("SettingsSwapButton-Settings")
        } onMaxTap: {
            print("SettingsSwapButton-Max")
        }
        SwitchSwapButton {
            print("SwitchSwapButton")
        }

    }
}
