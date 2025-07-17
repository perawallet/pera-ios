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

//   FeatureFlag.swift

import Foundation

enum FeatureFlag: String, CaseIterable {
    case discoverV5Enabled = "enable_discover_v5"
    case hdWalletEnabled = "enable_hd_wallet"
    case portfolioChartsEnabled = "enable_charts_portfolio"
    case accountsChartsEnabled = "enable_charts_accounts"
    case assetsChartsEnabled = "enable_charts_assets"

    var defaultValue: RemoteConfigValue {
        switch self {
        case .discoverV5Enabled:
            return .bool(false)
        case .hdWalletEnabled:
            return .bool(true)
        case .portfolioChartsEnabled:
            return .bool(false)
        case .accountsChartsEnabled:
            return .bool(false)
        case .assetsChartsEnabled:
            return .bool(false)
        }
    }
}
