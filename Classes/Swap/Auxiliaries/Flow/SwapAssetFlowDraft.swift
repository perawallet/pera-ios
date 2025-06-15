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

//   SwapAssetFlowDraft.swift

import Foundation

final class SwapAssetFlowDraft {
    var account: Account?

    /// <note>
    /// If assetInID is set, user should opt-in to the asset in if the selected account is not opted in to the asset.
    var assetInID: AssetID = 0
    /// <note>
    /// If assetOutID is set, user should opt-in to the asset out if the selected account is not opted in to the asset.
    var assetOutID: AssetID

    var assetIn: Asset? {
        guard let account = account else {
            return nil
        }

        return account[assetInID]
    }

    var assetOut: Asset? {
        guard let account = account else {
            return nil
        }

        return account[assetOutID]
    }

    init(
        account: Account? = nil,
        assetInID: AssetID = 0,
        assetOutID: AssetID? = nil,
        network: ALGAPI.Network = .mainnet
    ) {
        self.account = account
        self.assetInID = assetInID
        
        // Set intelligent default for assetOutID if not provided
        if let assetOutID = assetOutID {
            self.assetOutID = assetOutID
        } else {
            // If assetInID is Algo (0), default to USDC
            // If assetInID is an ASA (non-zero), default to Algo (0)
            if assetInID == 0 {
                self.assetOutID = ALGAsset.usdcAssetID(network)
            } else {
                self.assetOutID = 0
            }
        }
    }
}

extension SwapAssetFlowDraft {
    var isOptedInToAssetIn: Bool {
        return assetIn != nil
    }

    var shouldOptInToAssetOut: Bool {
        return assetOut == nil
    }

    var isOptedInToAssetOut: Bool {
        return assetOut != nil
    }
}
