//
//  algorand_tests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 7.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class DBDecodeTests: XCTestCase {

    func testAccountDecoding() {
        let accountInformation = try? JSONDecoder().decode(AccountInformation.self, from: Data())
    }

    func testAccountListDecoding() {
        let accounts = try? JSONDecoder().decode([AccountInformation].self, from: Data())
    }

    func testUserDecoding() {
        let user = try? JSONDecoder().decode(User.self, from: Data())
    }
}
