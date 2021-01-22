//
//  AssetRemovalViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class AssetRemovalViewModelTests: XCTestCase {

    private let assetDetail = Bundle.main.decode(AssetDetail.self, from: "HipoCoinAsset.json")

    func testActionColor() {
        let viewModel = AssetRemovalViewModel(assetDetail: assetDetail)
        XCTAssertEqual(viewModel.actionColor, Colors.General.error)
    }

    func testActionText() {
        let viewModel = AssetRemovalViewModel(assetDetail: assetDetail)
        XCTAssertEqual(viewModel.actionText, "title-remove".localized)
    }
}
