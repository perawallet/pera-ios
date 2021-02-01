//
//  AssetRemovalViewModelTests.swift

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
