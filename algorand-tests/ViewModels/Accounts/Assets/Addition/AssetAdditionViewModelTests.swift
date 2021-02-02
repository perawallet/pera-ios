//
//  AssetAdditionViewModelTests.swift

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
