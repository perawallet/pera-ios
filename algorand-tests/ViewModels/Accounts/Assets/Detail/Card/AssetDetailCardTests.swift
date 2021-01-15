//
//  AssetDetailCardTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 7.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class AssetDetailCardTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")
    private let currency = Bundle.main.decode(Currency.self, from: "Currency.json")
    private let assetDetail = Bundle.main.decode(AssetDetail.self, from: "HipoCoinAsset.json")

    func testAlgosCardAmount() {
        let viewModel = AlgosCardViewModel(account: account, currency: currency)
        XCTAssertEqual(viewModel.amount, "3,313.579804")
    }

    func testAlgosCardReward() {
        let viewModel = AlgosCardViewModel(account: account, currency: currency)
        XCTAssertEqual(viewModel.reward, "0.00 Rewards")
    }

    func testAlgosCardCurrency() {
        let viewModel = AlgosCardViewModel(account: account, currency: currency)
        XCTAssertEqual(viewModel.currency, "1,490.45 USD")
    }

    func testAssetCardName() {
        let viewModel = AssetCardViewModel(account: account, assetDetail: assetDetail)
        XCTAssertEqual(viewModel.name, "HipoCoin")
    }

    func testAssetCardAmount() {
        let viewModel = AssetCardViewModel(account: account, assetDetail: assetDetail)
        XCTAssertEqual(viewModel.amount, "2,759.49")
    }
}
