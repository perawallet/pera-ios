// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   WCSingleTransactionViewControllerAssetActionable.swift

import Foundation

protocol WCSingleTransactionViewControllerAssetActionable: WCSingleTransactionViewControllerActionable {
    func openInExplorer(_ assetDetail: AssetDetail?)
    func openAssetURL(_ assetDetail: AssetDetail?)
    func displayAssetMetadata(_ assetDetail: AssetDetail?)
}

extension WCSingleTransactionViewControllerAssetActionable where Self: WCSingleTransactionViewController {
    func openInExplorer(_ assetDetail: AssetDetail?) {
        if let assetId = assetDetail?.id,
           let url = URL(string: "https://algoexplorer.io/asset/\(String(assetId))") {
            open(url)
        }
    }

    func openAssetURL(_ assetDetail: AssetDetail?) {
        if let urlString = assetDetail?.url,
           let url = URL(string: urlString) {
            open(url)
        }
    }

    func displayAssetMetadata(_ assetDetail: AssetDetail?) {
        guard let transactionData = try? JSONEncoder().encode(assetDetail),
              let object = try? JSONSerialization.jsonObject(with: transactionData, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else {
            return
        }

        open(.jsonDisplay(jsonData: data, title: "wallet-connect-raw-transaction-title".localized), by: .present)
    }
}
