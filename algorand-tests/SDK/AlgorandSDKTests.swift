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

    override func setUp() {
        super.setUp()
    }

    func testIsValidAddress() {
        let validAddress = ""
        XCTAssertTrue(algorandSDK.isValidAddress(validAddress))
    }

    func testInvalidAddress() {
        let invalidAddress = ""
        XCTAssertFalse(algorandSDK.isValidAddress(invalidAddress))
    }

    func testMsgpackToJSON() {

    }

    func testJSONToMsgpack() {

    }

    func testSendAlgos() {

    }

    func testSendAsset() {

    }

    func testRemoveAsset() {

    }

    func testAddAsset() {

    }

    func testRekey() {

    }
}
