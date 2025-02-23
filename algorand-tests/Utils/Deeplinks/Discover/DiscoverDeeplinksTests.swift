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

//   DiscoverDeeplinksTests.swift

import XCTest

@testable import pera_staging

final class DiscoverDeeplinksTests: XCTestCase {
    
    func testDiscoverDeeplink() {
        let deepLinkToTest = URL(string: "perawallet://discover")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNil(path)
            let url = DiscoverURLGenerator.generateURL(destination: .home, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithBrowserPath() {
        let deepLinkToTest = URL(string: "perawallet://discover?path=main/browser")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/main/browser")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNotNil(path)
            let url = DiscoverURLGenerator.generateURL(path: path!, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithMarketsPath() {
        let deepLinkToTest = URL(string: "perawallet://discover?path=main/markets")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/main/markets")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNotNil(path)
            let url = DiscoverURLGenerator.generateURL(path: path!, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithAssetDetailPath() {
        let deepLinkToTest = URL(string: "perawallet://discover?path=token-detail/444035862")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/token-detail/444035862")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNotNil(path)
            let url = DiscoverURLGenerator.generateURL(path: path!, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithAlgoDetailPath() {
        let deepLinkToTest = URL(string: "perawallet://discover?path=token-detail/algo")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/token-detail/algo")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNotNil(path)
            let url = DiscoverURLGenerator.generateURL(path: path!, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithNewsListPath() {
        let deepLinkToTest = URL(string: "perawallet://discover?path=news")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/news")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNotNil(path)
            let url = DiscoverURLGenerator.generateURL(path: path!, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithNewsDetailPath() {
        let deepLinkToTest = URL(string: "perawallet://discover?path=news/3621282894169872116")!
        let expectedURL = URL(string: "https://discover-mobile-staging.perawallet.app/news/3621282894169872116")!
        
        switch deepLinkToTest.externalDeepLink {
        case .discover(let path):
            XCTAssertNotNil(path)
            let url = DiscoverURLGenerator.generateURL(path: path!, theme: .unspecified, session: nil)
            XCTAssertEqual(expectedURL.extractBaseURL(), url?.extractBaseURL())
            XCTAssertEqual(expectedURL.path, url?.path)
        default:
            XCTFail()
        }
    }
    
    func testDiscoverDeeplinkWithError() {
        let deepLinkToTest = URL(string: "perawallet://discove")!
        
        switch deepLinkToTest.externalDeepLink {
        case .other:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    

}
