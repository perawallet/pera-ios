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
    case swapFeePadding = "swap_fee_padding"
    case liquidAuthEnabled = "enable_liquid_auth"
    case liquidConnectEnabled = "enable_liquid_connect"
    case ledgerDeflexFilterEnabled = "enable_ledger_deflex_filter"
    case assetDetailV2Enabled = "enable_asset_detail_v2"
    case assetDetailV2EndpointEnabled = "enable_asset_detail_v2_endpoint"
    case webviewV2Enabled = "enable_webview_v2"
    case xoSwapEnabled = "enable_xo_swap"

    var defaultValue: RemoteConfigValue {
        switch self {
        case .swapFeePadding:
                .double(-1)
        case .liquidAuthEnabled:
                .bool(false)
        case .liquidConnectEnabled:
                .bool(false)
        case .ledgerDeflexFilterEnabled:
                .bool(false)
        case .assetDetailV2Enabled:
                .bool(false)
        case .assetDetailV2EndpointEnabled:
                .bool(false)
        case .webviewV2Enabled:
                .bool(false)
        case .xoSwapEnabled:
                .bool(false)
        }
    }
    
    public static func ==(lhs: FeatureFlag, rhs: FeatureFlag) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
