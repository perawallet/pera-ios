//
//  TransactionParamsTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 13.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class TransactionParamsTests: XCTestCase {

    private let params = Bundle.main.decode(TransactionParams.self, from: "TransactionParams.json")

    func testGetProjectedTransactionFee() {
        let projectedFee = params.getProjectedTransactionFee()
        XCTAssertEqual(projectedFee, 1000)
    }

    func testGetProjectedTransactionFeeWithData() {
        let projectedFee = params.getProjectedTransactionFee(from: 300)
        XCTAssertEqual(projectedFee, 1000)
    }
}
