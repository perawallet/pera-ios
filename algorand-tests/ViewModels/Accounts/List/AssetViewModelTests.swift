//
//  AssetViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class AssetViewModelTests: XCTestCase {

    private let assetDetail = Bundle.main.decode(AssetDetail.self, from: "HipoCoinAsset.json")
    private let asset = Bundle.main.decode(Asset.self, from: "Asset.json")

    func testAmount() {
        let viewModel = AssetViewModel(assetDetail: assetDetail, asset: asset)
        XCTAssertEqual(viewModel.amount, "2,759.49")
    }
}
