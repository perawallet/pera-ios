//
//  RewardDetailViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

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
