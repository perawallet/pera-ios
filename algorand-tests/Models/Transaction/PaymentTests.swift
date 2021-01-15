//
//  PaymentTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 13.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class PaymentTests: XCTestCase {

    private let payment = Bundle.main.decode(Payment.self, from: "Payment.json")

    func testAmountForTransaction() {
        let amount = payment.amountForTransaction(includesCloseAmount: false)
        XCTAssertEqual(amount, 200000)
    }

    func testAmountForTransactionWithClose() {
        let amount = payment.amountForTransaction(includesCloseAmount: true)
        XCTAssertEqual(amount, 200100)
    }

    func testCloseAmountForTransaction() {
        let closeAmount = payment.closeAmountForTransaction()
        XCTAssertEqual(closeAmount, 100)
    }
}
