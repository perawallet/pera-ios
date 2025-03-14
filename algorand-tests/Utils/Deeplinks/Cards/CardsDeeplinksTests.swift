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

//   CardsDeeplinksTests.swift

import XCTest

@testable import pera_staging

final class CardsDeeplinksTests: XCTestCase {
    
    func testCardsDeeplink() {
        let deepLinkToTest = URL(string: "perawallet://cards")!
        let expectedURL = URL(string: "https://cards-mobile-staging.perawallet.app/")!
        
        switch deepLinkToTest.externalDeepLink {
        case .cards(let path):
            XCTAssertNil(path)
            let url = CardsURLGenerator.generateURL(destination: .welcome, theme: .unspecified, session: nil, network: .testnet)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
        default:
            XCTFail()
        }
    }
    
    func testCardsDeeplinkWithOnboardingPath() {
        let deepLinkToTest = URL(string: "perawallet://cards?path=onboarding/select-country")!
        let expectedURL = URL(string: "https://cards-mobile-staging.perawallet.app/onboarding/select-country")!
        
        switch deepLinkToTest.externalDeepLink {
        case .cards(let path):
            XCTAssertNotNil(path)
            let url = CardsURLGenerator.generateURL(destination: .other(path: path), theme: .unspecified, session: nil, network: .testnet)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testCardsDeeplinkWithDepositPath() {
        let deepLinkToTest = URL(string: "perawallet://cards?path=card/deposit")!
        let expectedURL = URL(string: "https://cards-mobile-staging.perawallet.app/card/deposit")!
        
        switch deepLinkToTest.externalDeepLink {
        case .cards(let path):
            XCTAssertNotNil(path)
            let url = CardsURLGenerator.generateURL(destination: .other(path: path), theme: .unspecified, session: nil, network: .testnet)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testCardsDeeplinkWithWithdrawPath() {
        let deepLinkToTest = URL(string: "perawallet://cards?path=card/withdraw")!
        let expectedURL = URL(string: "https://cards-mobile-staging.perawallet.app/card/withdraw")!
        
        switch deepLinkToTest.externalDeepLink {
        case .cards(let path):
            XCTAssertNotNil(path)
            let url = CardsURLGenerator.generateURL(destination: .other(path: path), theme: .unspecified, session: nil, network: .testnet)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testCardsDeeplinkWithTransactionsPath() {
        let deepLinkToTest = URL(string: "perawallet://cards?path=card/transactions")!
        let expectedURL = URL(string: "https://cards-mobile-staging.perawallet.app/card/transactions")!
        
        switch deepLinkToTest.externalDeepLink {
        case .cards(let path):
            XCTAssertNotNil(path)
            let url = CardsURLGenerator.generateURL(destination: .other(path: path), theme: .unspecified, session: nil, network: .testnet)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testCardsDeeplinkWithError() {
        let deepLinkToTest = URL(string: "perawallet://card")!
        
        XCTAssertNil(deepLinkToTest.externalDeepLink)
    }
    

}
