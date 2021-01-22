//
//  AssetAdditionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetAdditionViewModel {
    private(set) var backgroundColor: UIColor?
    private(set) var assetDetail: AssetDetail?
    private(set) var actionColor: UIColor?
    private(set) var id: String?

    init(assetSearchResult: AssetSearchResult) {
        setBackgroundColor()
        setAssetDetail(from: assetSearchResult)
        setActionColor()
        setId(from: assetSearchResult)
    }

    private func setBackgroundColor() {
        backgroundColor = Colors.Background.tertiary
    }

    private func setAssetDetail(from assetSearchResult: AssetSearchResult) {
        assetDetail = AssetDetail(searchResult: assetSearchResult)
    }

    private func setActionColor() {
        actionColor = Colors.Text.tertiary
    }

    private func setId(from assetSearchResult: AssetSearchResult) {
        id = "\(assetSearchResult.id)"
    }
}
