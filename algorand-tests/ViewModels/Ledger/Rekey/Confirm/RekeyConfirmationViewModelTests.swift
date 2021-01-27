//
//  RekeyConfirmationViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class RekeyConfirmationViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testAssetText() {
        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1")
        XCTAssertEqual(viewModel.assetText, "+5 more assets")
    }

    func testOldTransitionTitle() {
        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1")
        XCTAssertEqual(viewModel.oldTransitionTitle, "Passphrase")
    }

    func testOldTransitionValue() {
        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1")
        XCTAssertEqual(viewModel.oldTransitionValue, "*********")
    }

    func testNewTransitionValue() {
        let viewModel = RekeyConfirmationViewModel(account: account, ledgerName: "Ledger Name 1")
        XCTAssertEqual(viewModel.newTransitionValue, "Ledger Name 1")
    }
}
