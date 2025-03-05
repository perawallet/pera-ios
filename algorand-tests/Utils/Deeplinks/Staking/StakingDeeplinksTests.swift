// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   StakingDeeplinksTests.swift

import XCTest

@testable import pera_staging

final class StakingDeeplinksTests: XCTestCase {
    
    func testStakingDeeplink() {
        let deepLinkToTest = URL(string: "perawallet://staking")!
        let expectedURL = URL(string: "https://staking-mobile-staging.perawallet.app/")!
        
        switch deepLinkToTest.externalDeepLink {
        case .staking(let path):
            XCTAssertNil(path)
            let url = StakingURLGenerator.generateURL(destination: .list, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
        default:
            XCTFail()
        }
    }
    
    func testStakingDeeplinkWithPath() {
        let deepLinkToTest = URL(string: "perawallet://staking?path=test")!
        let expectedURL = URL(string: "https://staking-mobile-staging.perawallet.app/")!
        
        switch deepLinkToTest.externalDeepLink {
        case .staking(let path):
            XCTAssertNotNil(path)
            let url = StakingURLGenerator.generateURL(destination: .list, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
        default:
            XCTFail()
        }
    }
    
    func testStakingDeeplinkWithError() {
        let deepLinkToTest = URL(string: "perawallet://stakig")!
        
        XCTAssertNil(deepLinkToTest.externalDeepLink)
    }
}
