//
//  AssetAdditionViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class AssetAdditionViewModelTests: XCTestCase {

    private let assetSearchResult = Bundle.main.decode(AssetSearchResult.self, from: "AssetSearchResult.json")

    func testId() {
        let viewModel = AssetAdditionViewModel(assetSearchResult: assetSearchResult)
        XCTAssertEqual(viewModel.id, "11711")
    }

    func testActionColor() {
        let viewModel = AssetAdditionViewModel(assetSearchResult: assetSearchResult)
        XCTAssertEqual(viewModel.actionColor, Colors.Text.tertiary)
    }
}
