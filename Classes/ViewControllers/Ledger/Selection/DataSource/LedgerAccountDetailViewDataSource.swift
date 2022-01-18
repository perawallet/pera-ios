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
//  LedgerAccountDetailViewDataSource.swift

import MacaroonUtils
import UIKit

final class LedgerAccountDetailViewDataSource: NSObject {
    weak var delegate: LedgerAccountDetailViewDataSourceDelegate?

    private let sharedDataController: SharedDataController
    private let api: ALGAPI
    private let loadingController: LoadingController?

    init(
        sharedDataController: SharedDataController,
        api: ALGAPI,
        loadingController: LoadingController?
    ) {
        self.sharedDataController = sharedDataController
        self.api = api
        self.loadingController = loadingController

        super.init()
    }

    func fetchAssets(for account: Account) {
        guard let assets = account.assets,
              !assets.isEmpty else {
            delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
            return
        }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        for (index, asset) in assets.enumerated() {
            if let assetDetail = sharedDataController.assetDetailCollection[asset.id] {
                let compoundAsset = CompoundAsset(asset, assetDetail)
                account.append(compoundAsset)

                if index == assets.count - 1 {
                    loadingController?.stopLoading()
                    delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
                }
            } else {
                api.getAssetDetails(AssetFetchQuery(ids: [asset.id])) { assetResponse in
                    switch assetResponse {
                    case .success(let assetDetailResponse):
                        self.composeAssetDetail(assetDetailResponse.results[0], of: account, with: asset)
                    case .failure:
                        account.removeAsset(asset.id)
                    }

                    if index == assets.count - 1 {
                        self.loadingController?.stopLoading()
                        self.delegate?.ledgerAccountDetailViewDataSource(self, didReturn: account)
                    }
                }
            }
        }
    }

    private func composeAssetDetail(_ assetDetail: AssetInformation, of account: Account, with asset: Asset) {
        let compoundAsset = CompoundAsset(asset, assetDetail)
        account.append(compoundAsset)
        
        sharedDataController.assetDetailCollection[asset.id] = assetDetail
    }
}

protocol LedgerAccountDetailViewDataSourceDelegate: AnyObject {
    func ledgerAccountDetailViewDataSource(
        _ ledgerAccountDetailViewDataSource: LedgerAccountDetailViewDataSource,
        didReturn account: Account
    )
}
