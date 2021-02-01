//
//  AssetDetailTests.swift

import XCTest

@testable import algorand_staging

class AssetDetailTests: XCTestCase {
    
    private let assetDetail = Bundle.main.decode(AssetDetail.self, from: "HipoCoinAsset.json")

    func testGetDisplayNames() {
        let displayNames = assetDetail.getDisplayNames()
        XCTAssertEqual(displayNames.0, ("HipoCoin"))
        XCTAssertEqual(displayNames.1, ("HIPO"))
    }

    func testHasOnlyAssetName() {
        XCTAssertFalse(assetDetail.hasOnlyAssetName())
    }

    func testHasNoDisplayName() {
        XCTAssertFalse(assetDetail.hasNoDisplayName())
    }

    func testGetAssetName() {
        let assetName = assetDetail.getAssetName()
        XCTAssertEqual(assetName, ("HipoCoin"))
    }
}
