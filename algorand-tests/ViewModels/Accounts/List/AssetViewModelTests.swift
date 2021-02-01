//
//  AssetViewModelTests.swift

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
