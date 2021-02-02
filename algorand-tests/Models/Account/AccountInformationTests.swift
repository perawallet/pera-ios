//
//  AccountInformationTests.swift

import XCTest

@testable import algorand_staging

class AccountInformationTests: XCTestCase {

    private let account = Bundle.main.decode(AccountInformation.self, from: "AccountInformationA.json")
    
    func testAddRekeyDetail() {
        let accountB = Bundle.main.decode(Account.self, from: "AccountA.json")
        let ledgerDetail = Bundle.main.decode(LedgerDetail.self, from: "LedgerDetail.json")
        account.addRekeyDetail(ledgerDetail, for: accountB.address)
        XCTAssertNotNil(account.rekeyDetail)
    }
}
