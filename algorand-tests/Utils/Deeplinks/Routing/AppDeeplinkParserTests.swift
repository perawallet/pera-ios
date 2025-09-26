// Copyright 2022-2025 Pera Wallet, LDA

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
//  AppDeeplinkParserTests.swift

import XCTest
@testable import pera_staging
@testable import pera_wallet_core

final class AppDeeplinkParserTests: XCTestCase {
    
    func testIsAppBasedDeeplink() {
        let appHostURL = URL(string: "perawallet://app/asset-transfer/?assetId=0")!
        XCTAssertTrue(AppDeeplinkParser.isAppBasedDeeplink(appHostURL))
        
        let universalLinkURL = URL(string: "https://perawallet.app/qr/perawallet/app/add-contact/?address=ABC123")!
        XCTAssertTrue(AppDeeplinkParser.isAppBasedDeeplink(universalLinkURL))
        
        let legacyURL = URL(string: "perawallet://ABC123?amount=1000")!
        XCTAssertFalse(AppDeeplinkParser.isAppBasedDeeplink(legacyURL))
        
        let discoverURL = URL(string: "perawallet://discover?path=main")!
        XCTAssertFalse(AppDeeplinkParser.isAppBasedDeeplink(discoverURL))
    }
    
    func testParseEndpointFromDeeplink() {
        let appHostURL = URL(string: "perawallet://app/asset-transfer/?assetId=0")!
        let endpoint1 = AppDeeplinkParser.parseEndpoint(from: appHostURL)
        XCTAssertEqual(endpoint1, .assetTransfer)
        
        let contactURL = URL(string: "perawallet://app/add-contact/?address=ABC123")!
        let endpoint2 = AppDeeplinkParser.parseEndpoint(from: contactURL)
        XCTAssertEqual(endpoint2, .addContact)
        
        let buyURL = URL(string: "perawallet://app/buy/?address=BUY123")!
        let endpoint3 = AppDeeplinkParser.parseEndpoint(from: buyURL)
        XCTAssertEqual(endpoint3, .buy)
    }
    
    func testParseEndpointFromUniversalLink() {
        let universalURL = URL(string: "https://perawallet.app/qr/perawallet/app/asset-detail/?address=ABC123&assetId=31566704")!
        let endpoint = AppDeeplinkParser.parseEndpoint(from: universalURL)
        XCTAssertEqual(endpoint, .assetDetail)
        
        let wcURL = URL(string: "https://perawallet.app/qr/perawallet/app/wallet-connect/?walletConnectUrl=wc:test")!
        let wcEndpoint = AppDeeplinkParser.parseEndpoint(from: wcURL)
        XCTAssertEqual(wcEndpoint, .walletConnect)
        
        let sellURL = URL(string: "https://perawallet.app/qr/perawallet/app/sell/?address=SELL123")!
        let sellEndpoint = AppDeeplinkParser.parseEndpoint(from: sellURL)
        XCTAssertEqual(sellEndpoint, .sell)
    }
    
    func testParseEndpointInvalid() {
        let legacyURL = URL(string: "perawallet://ABC123?amount=1000")!
        XCTAssertNil(AppDeeplinkParser.parseEndpoint(from: legacyURL))
        
        let noAppURL = URL(string: "perawallet://discover?path=main")!
        XCTAssertNil(AppDeeplinkParser.parseEndpoint(from: noAppURL))
        
        let invalidURL = URL(string: "perawallet://app/invalid-endpoint/?param=test")!
        XCTAssertNil(AppDeeplinkParser.parseEndpoint(from: invalidURL))
    }
    
    func testAllEndpointCases() {
        let testCases: [(String, AppEndpoint)] = [
            ("asset-transfer", .assetTransfer),
            ("asset-opt-in", .assetOptIn),
            ("keyreg", .keyReg),
            ("address-action", .addressAction),
            ("add-contact", .addContact),
            ("edit-contact", .editContact),
            ("add-watch-account", .addWatchAccount),
            ("register-watch-account", .registerWatchAccount),
            ("receiver-account-selection", .receiverAccountSelection),
            ("address-actions", .addressActions),
            ("recover-address", .recoverAddress),
            ("wallet-connect", .walletConnect),
            ("asset-detail", .assetDetail),
            ("asset-inbox", .assetInbox),
            ("discover-browser", .discoverBrowser),
            ("discover-path", .discoverPath),
            ("cards-path", .cardsPath),
            ("staking-path", .stakingPath),
            ("buy", .buy),
            ("sell", .sell),
            ("account-detail", .accountDetail)
        ]
        
        for (pathComponent, expectedEndpoint) in testCases {
            let url = URL(string: "perawallet://app/\(pathComponent)/?test=param")!
            let parsedEndpoint = AppDeeplinkParser.parseEndpoint(from: url)
            XCTAssertEqual(parsedEndpoint, expectedEndpoint, "Failed to parse endpoint: \(pathComponent)")
        }
    }
    
    func testComplexPaths() {
        let complexURL = URL(string: "https://perawallet.app/qr/perawallet/app/asset-transfer/extra/path/?assetId=0")!
        let endpoint = AppDeeplinkParser.parseEndpoint(from: complexURL)
        XCTAssertEqual(endpoint, .assetTransfer)
        
        let noPathURL = URL(string: "perawallet://app/?test=param")!
        XCTAssertNil(AppDeeplinkParser.parseEndpoint(from: noPathURL))
        
        let emptyPathURL = URL(string: "perawallet://app//?test=param")!
        XCTAssertNil(AppDeeplinkParser.parseEndpoint(from: emptyPathURL))
    }
}
