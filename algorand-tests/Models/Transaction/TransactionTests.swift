//
//  TransactionTests.swift

import XCTest

@testable import algorand_staging

class TransactionTests: XCTestCase {

    private let algoTransaction = Bundle.main.decode(Transaction.self, from: "AlgoTransaction.json")
    private let assetTransaction = Bundle.main.decode(Transaction.self, from: "AssetTransaction.json")
    private let assetAdditionTransaction = Bundle.main.decode(Transaction.self, from: "AssetTransaction.json")
    
    func testIsPending() {
        XCTAssertFalse(algoTransaction.isPending())
    }

    func testIsAssetAdditionTransaction() {
        let address = "X2YHQU7W6OJG66TMLL3PZ7JQS2D42YEGATBBNDXH22Q6JSNOFR6LVZYXXM"
        XCTAssertTrue(assetAdditionTransaction.isAssetAdditionTransaction(for: address))
    }

    func testNoteRepresentation() {
        let note = assetTransaction.noteRepresentation()
        XCTAssertEqual(note, "hey")
    }
}
