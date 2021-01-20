//
//  SendTransactionViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 19.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class SendTransactionViewModelTests: XCTestCase {

    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    private var algosDraft: AlgosTransactionSendDraft {
        return AlgosTransactionSendDraft(
            from: account,
            toAccount: "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM",
            amount: 1234567,
            fee: 1000,
            isMaxTransaction: false,
            identifier: "id",
            note: "This is note"
        )
    }

    private var assetDraft: AssetTransactionSendDraft {
        return AssetTransactionSendDraft(
            from: account,
            toAccount: "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM",
            amount: 1234567,
            fee: 1000,
            isMaxTransaction: false,
            identifier: "id",
            assetIndex: 11711,
            assetCreator: "",
            closeAssetsTo: nil,
            assetDecimalFraction: 2,
            isVerifiedAsset: false,
            note: "This is note"
        )
    }

    func testButtonTitle() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertEqual(viewModel.buttonTitle, "Send Algos")
    }

    func testAssetName() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertEqual(viewModel.assetName, "Algos")
    }

    func testAssetId() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertNil(viewModel.assetId)
    }

    func testReceiverName() {
        let viewModel = SendTransactionViewModel(transactionDraft: algosDraft)
        XCTAssertEqual(viewModel.receiverName, "X2YHQU...VZYXXM")
    }

    func testButtonTitleAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.buttonTitle, "Send HipoCoin")
    }

    func testAssetNameForAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.assetName, "HIPO")
    }

    func testAssetIdAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.assetId, "11711")
    }

    func testReceiverNameAssetTransaction() {
        let viewModel = SendTransactionViewModel(transactionDraft: assetDraft)
        XCTAssertEqual(viewModel.receiverName, "X2YHQU...VZYXXM")
    }
}
