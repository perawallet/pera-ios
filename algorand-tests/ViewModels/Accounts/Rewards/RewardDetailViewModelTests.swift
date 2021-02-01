//
//  RewardDetailViewModelTests.swift

import XCTest

@testable import algorand_staging

class RewardDetailViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testRewardAmount() {
        let viewModel = RewardDetailViewModel(account: account)
        let amount = viewModel.amount
        XCTAssertEqual(amount, "0.01")
    }
}
