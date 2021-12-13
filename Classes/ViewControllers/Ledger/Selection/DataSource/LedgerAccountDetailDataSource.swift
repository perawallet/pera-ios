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
//   LedgerAccountDetailDataSource.swift

import MacaroonUIKit
import UIKit

final class LedgerAccountDetailDataSource: NSObject {
    private let api: ALGAPI
    private let loadingController: LoadingController?
    private let account: Account
    private let rekeyedAccounts: [Account]

    private var assetPreviews: [AssetPreviewModel] = []

    init(api: ALGAPI, loadingController: LoadingController?, account: Account, rekeyedAccounts: [Account]) {
        self.api = api
        self.loadingController = loadingController
        self.account = account
        self.rekeyedAccounts = rekeyedAccounts
        super.init()

        self.fetchAssets(for: account)
    }
}

extension LedgerAccountDetailDataSource: UICollectionViewDataSource {
    private var sections: [Section] {
        var sections: [Section] = [.ledgerAccount]
        if !assetPreviews.isEmpty { sections.append(.assets) }
        if !rekeyedAccounts.isEmpty { sections.append(.rekeyedAccounts) }
        return sections
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .ledgerAccount:
            return 1
        case .assets:
            return assetPreviews.count
        case .rekeyedAccounts:
            return account.isRekeyed() ? 1 : rekeyedAccounts.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .ledgerAccount:
            return cellForLedgerAccount(collectionView, cellForItemAt: indexPath)
        case .assets:
            return cellForAsset(collectionView, cellForItemAt: indexPath)
        case .rekeyedAccounts:
            return cellForRekeyedAccount(collectionView, cellForItemAt: indexPath)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueHeader(
            LedgerAccountDetailSectionHeaderReusableView.self,
            at: indexPath
        )
        headerView.bindData(LedgerAccountDetailSectionHeaderViewModel(section: sections[indexPath.section], account: account))
        return headerView
    }
}

extension LedgerAccountDetailDataSource {
    func cellForLedgerAccount(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)

        let accountNameViewModel = AccountNameViewModel(account: account)
        cell.bindData(
            AccountPreviewViewModel(
                AccountPreviewModel(
                    accountType: account.type,
                    accountImageType: .orange,
                    accountName: accountNameViewModel.name,
                    assetsAndNFTs: nil,
                    assetValue: nil,
                    secondaryAssetValue: nil)
            )
        )
        return cell
    }

    func cellForAsset(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AssetPreviewCell.self, at: indexPath)
        cell.customize(AssetPreviewViewCommonTheme())
        cell.bindData(AssetPreviewViewModel(assetPreviews[indexPath.row]))
        return cell
    }

    func cellForRekeyedAccount(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)

        if account.isRekeyed() {
            let accountNameViewModel = AuthAccountNameViewModel(account)
            cell.bindData(accountNameViewModel)
        } else {
            let rekeyedAccount = rekeyedAccounts[indexPath.row]
            let accountNameViewModel = AccountNameViewModel(account: rekeyedAccount)
            cell.bindData(accountNameViewModel)
        }
        return cell
    }
}

extension LedgerAccountDetailDataSource {
    enum Section: Int {
        case ledgerAccount = 0
        case assets = 1
        case rekeyedAccounts = 2
    }
}

extension LedgerAccountDetailDataSource {
    private func fetchAssets(for account: Account) {
        let assetPreviewModel = AssetPreviewModelAdapter.adapt(account)
        assetPreviews.append(assetPreviewModel)

        guard let assets = account.assets,
              !assets.isEmpty else {
                  return
              }

        loadingController?.startLoadingWithMessage("title-loading".localized)

        assets.forEach { asset in
            if let assetDetail = api.session.assetDetails[asset.id] {
                account.assetDetails.append(assetDetail)
                let assetPreviewModel = AssetPreviewModelAdapter.adapt((assetDetail: assetDetail, asset: asset))
                assetPreviews.append(assetPreviewModel)
            } else {
                api.getAssetDetails(AssetFetchDraft(assetId: "\(asset.id)")) { [weak self] assetResponse in
                    switch assetResponse {
                    case .success(let assetDetailResponse):
                        self?.composeAssetDetail(assetDetailResponse.assetDetail, of: account, with: asset)
                    case .failure:
                        account.removeAsset(asset.id)
                    }
                }
            }
        }
        loadingController?.stopLoading()
    }

    private func composeAssetDetail(_ assetDetail: AssetDetail, of account: Account, with asset: Asset) {
        var assetDetail = assetDetail
        setVerifiedIfNeeded(&assetDetail, with: asset.id)
        account.assetDetails.append(assetDetail)
        api.session.assetDetails[asset.id] = assetDetail
        let assetPreviewModel = AssetPreviewModelAdapter.adapt((assetDetail: assetDetail, asset: asset))
        assetPreviews.append(assetPreviewModel)
    }

    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail, with id: Int64) {
        if let verifiedAssets = api.session.verifiedAssets,
           verifiedAssets.contains(where: { $0.id == id }) {
            assetDetail.isVerified = true
        }
    }
}
