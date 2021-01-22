//
//  LedgerAccountSelectionViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class LedgerAccountSelectionViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testSubviews() {
        let viewModel = LedgerAccountSelectionViewModel(account: account, isMultiSelect: true, isSelected: false)
        XCTAssertEqual(viewModel.subviews.count, 3)
    }
}
