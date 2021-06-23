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
//   AlgorandSDKTests.swift

import XCTest

@testable import algorand_staging

class AlgorandSDKTests: XCTestCase {

    private let algorandSDK = AlgorandSDK()
    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")
    private let accountAddress = "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM"
    private let transactionParams = Bundle.main.decode(TransactionParams.self, from: "TransactionParams.json")

    override func setUp() {
        super.setUp()
    }

    func testIsValidAddress() {
        XCTAssertTrue(algorandSDK.isValidAddress(accountAddress))
    }

    func testInvalidAddress() {
        let invalidAddress = "ASDXYZ"
        XCTAssertFalse(algorandSDK.isValidAddress(invalidAddress))
    }

    func testMsgpackToJSON() {
        let msgpack = Data(base64Encoded: "3wAAAAGkdGVzdKR0ZXN0==")
        let resultJson = "{\"test\": \"test\"}"
        var error: NSError?
        let result = algorandSDK.msgpackToJSON(msgpack, error: &error)
        XCTAssertEqual(result, resultJson)
        XCTAssertNil(error)
    }

    func testJSONToMsgpack() {
        let msgpack = Data(base64Encoded: "3wAAAAGkdGVzdKR0ZXN0==")
        let resultJson = "{\"test\": \"test\"}"
        var error: NSError?
        let result = algorandSDK.jsonToMsgpack(resultJson, error: &error)
        XCTAssertEqual(msgpack, result)
        XCTAssertNil(error)
    }

    func testSendAlgos() {
        let draft = AlgosTransactionDraft(
            from: account,
            toAccount: accountAddress,
            transactionParams: transactionParams,
            amount: 10000,
            isMaxTransaction: false,
            note: nil
        )

        var error: NSError?
        let transaction = algorandSDK.sendAlgos(with: draft, error: &error)
        XCTAssertNotNil(transaction)
        XCTAssertNil(error)
    }

    func testSendAsset() {
        let draft = AssetTransactionDraft(
            from: account,
            toAccount: accountAddress,
            transactionParams: transactionParams,
            amount: 100,
            assetIndex: 11711,
            note: nil
        )

        var error: NSError?
        let transaction = algorandSDK.sendAsset(with: draft, error: &error)
        XCTAssertNotNil(transaction)
        XCTAssertNil(error)
    }

    func testRemoveAsset() {
        let draft = AssetRemovalDraft(
            from: account,
            transactionParams: transactionParams,
            amount: 0,
            assetCreatorAddress: "",
            assetIndex: 11711,
            note: nil
        )

        var error: NSError?
        let transaction = algorandSDK.removeAsset(with: draft, error: &error)
        XCTAssertNotNil(transaction)
        XCTAssertNil(error)
    }

    func testAddAsset() {
        let draft = AssetAdditionDraft(from: account, transactionParams: transactionParams, assetIndex: 11711, note: nil)
        var error: NSError?
        let transaction = algorandSDK.addAsset(with: draft, error: &error)
        XCTAssertNotNil(transaction)
        XCTAssertNil(error)
    }

    func testRekey() {
        let draft = RekeyTransactionDraft(from: account, rekeyedAccount: "", transactionParams: transactionParams)
        var error: NSError?
        let transaction = algorandSDK.rekeyAccount(with: draft, error: &error)
        XCTAssertNotNil(transaction)
        XCTAssertNil(error)
    }
}
