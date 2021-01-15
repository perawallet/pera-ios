//
//  AccountTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 13.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class AccountTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")
    private let accountB = Bundle.main.decode(Account.self, from: "AccountA.json")
    private let assetDetail = Bundle.main.decode(AssetDetail.self, from: "HipoCoinAsset.json")

    func testAmount() {
        let amount = account.amount(for: assetDetail)
        XCTAssertEqual(amount, 2759.49)
    }

    func testAmountDisplayWithFraction() {
        let amountDisplayWithFraction = account.amountDisplayWithFraction(for: assetDetail)
        XCTAssertEqual(amountDisplayWithFraction, "2,759.49")
    }

    func testIsThereAnyDifferentAsset() {
        let isThereAnyDifferentAsset = account.isThereAnyDifferentAsset()
        XCTAssertTrue(isThereAnyDifferentAsset)
    }

    func testDoesAccountHasParticipationKey() {
        let doesAccountHasParticipationKey = account.doesAccountHasParticipationKey()
        XCTAssertFalse(doesAccountHasParticipationKey)
    }

    func testHasDifferentAssets() {
        let hasDifferentAssets = account.hasDifferentAssets(than: accountB)
        XCTAssertFalse(hasDifferentAssets)
    }

    func testRemoveAssets() {
        let assetCount = account.assetDetails.count
        account.removeAsset(assetDetail.id)
        XCTAssertNotEqual(assetCount, account.assetDetails.count)
    }

    func testContainsAsset() {
        let containsAsset = account.containsAsset(assetDetail.id)
        XCTAssertTrue(containsAsset)
    }

    func testRequiresLedgerConnection() {
        let requiresLedgerConnection = account.requiresLedgerConnection()
        XCTAssertFalse(requiresLedgerConnection)
    }

    func testAddRekeyDetail() {
        let ledgerDetail = Bundle.main.decode(LedgerDetail.self, from: "LedgerDetail.json")
        account.addRekeyDetail(ledgerDetail, for: accountB.address)
        XCTAssertNotNil(account.rekeyDetail)
    }

    func testCurrentLedgerDetailForRekey() {
        let rekeyedAccount = Bundle.main.decode(Account.self, from: "RekeyedAccount.json")
        let currentLedgerDetail = rekeyedAccount.currentLedgerDetail
        XCTAssertEqual(currentLedgerDetail?.id, currentLedgerDetail?.id)
    }

    func testCurrentLedgerDetailForLedger() {
        let ledgerAccount = Bundle.main.decode(Account.self, from: "LedgerAccount.json")
        let currentLedgerDetail = ledgerAccount.currentLedgerDetail
        XCTAssertEqual(currentLedgerDetail?.id, currentLedgerDetail?.id)
    }
}
