//
//  LedgerAccountDetailViewModelTests.swift

import XCTest

@testable import algorand_staging

class LedgerAccountDetailViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")
    private let accountB = Bundle.main.decode(Account.self, from: "AccountB.json")

    func testSubtitle() {
        let viewModel = LedgerAccountDetailViewModel(account: account, rekeyedAccounts: [accountB])
        XCTAssertEqual(viewModel.subtitle, "Can sign for these accounts")
    }

    func testAssetViews() {
        let viewModel = LedgerAccountDetailViewModel(account: account, rekeyedAccounts: [accountB])
        XCTAssertEqual(viewModel.assetViews.count, 8)
    }

    func testRekeyedAccountViews() {
        let viewModel = LedgerAccountDetailViewModel(account: account, rekeyedAccounts: [accountB])
        XCTAssertEqual(viewModel.rekeyedAccountViews?.count, 1)
    }
}
