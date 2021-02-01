//
//  AlgoAssetViewModelTests.swift

import XCTest

@testable import algorand_staging

class AlgoAssetViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testAmount() {
        let viewModel = AlgoAssetViewModel(account: account)
        XCTAssertEqual(viewModel.amount, "3,313.579804")
    }
}
