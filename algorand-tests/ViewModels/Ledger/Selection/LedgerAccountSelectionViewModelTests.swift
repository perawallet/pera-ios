//
//  LedgerAccountSelectionViewModelTests.swift

import XCTest

@testable import algorand_staging

class LedgerAccountSelectionViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testSubviews() {
        let viewModel = LedgerAccountSelectionViewModel(account: account, isMultiSelect: true, isSelected: false)
        XCTAssertEqual(viewModel.subviews.count, 3)
    }
}
