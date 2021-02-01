//
//  QRTextTests.swift

import XCTest

@testable import algorand_staging

class QRTextTests: XCTestCase {

    func testQRTextForAddress() {
        let qrText = QRText(mode: .address, address: "algorandaddressforqr", label: "value")
        XCTAssertEqual(qrText.qrText(), "algorand://algorandaddressforqr?label=value")
    }

    func testQRTextForRequest() {
        let qrText = QRText(mode: .assetRequest, address: "algorandaddressforqr", amount: 123, asset: 11711)
        XCTAssertEqual(qrText.qrText(), "algorand://algorandaddressforqr?amount=123&asset=11711")
    }
}
