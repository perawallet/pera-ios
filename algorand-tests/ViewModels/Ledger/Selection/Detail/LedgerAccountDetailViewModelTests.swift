// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
