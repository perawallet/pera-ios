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

public enum FeatureFlag: String, CaseIterable {
    case portfolioChartsEnabled = "enable_charts_portfolio"
    case accountsChartsEnabled = "enable_charts_accounts"
    case assetsChartsEnabled = "enable_charts_assets"
    case swapV2Enabled = "enable_swap_v2"
    case swapFeePadding = "swap_fee_padding"
    case liquidAuthEnabled = "enable_liquid_auth"
    case liquidConnectEnabled = "enable_liquid_connect"

    var defaultValue: RemoteConfigValue {
        switch self {
        case .portfolioChartsEnabled:
            return .bool(false)
        case .accountsChartsEnabled:
            return .bool(false)
        case .assetsChartsEnabled:
            return .bool(false)
        case .swapV2Enabled:
            return .bool(false)
        case .swapFeePadding:
            return .double(-1)
        case .liquidAuthEnabled:
            return .bool(false)
        case .liquidConnectEnabled:
            return .bool(false)
        }
    }
    
    public static func ==(lhs: FeatureFlag, rhs: FeatureFlag) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
