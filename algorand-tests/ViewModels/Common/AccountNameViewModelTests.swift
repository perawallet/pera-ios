//
//  AccountNameViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class AccountNameViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testImage() {
        let viewModel = AccountNameViewModel(account: account)
        XCTAssertEqual(viewModel.image, img("icon-account-type-standard"))
    }

    func testName() {
        let viewModel = AccountNameViewModel(account: account)
        XCTAssertEqual(viewModel.name, "Chase")
    }
}
