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
//  DeeplinkQRTests.swift

import XCTest
@testable import pera_staging
@testable import pera_wallet_core

final class DeeplinkQRTests: XCTestCase {
    
    func testAppBasedDeeplinkParsing() {
        let assetTransferURL = URL(string: "perawallet://app/asset-transfer/?assetId=0&receiverAddress=ABC123&amount=1000&note=hello")!
        let assetTransferQR = DeeplinkQR(url: assetTransferURL).qrText()
        
        XCTAssertNotNil(assetTransferQR)
        XCTAssertEqual(assetTransferQR?.mode, .algosRequest)
        XCTAssertEqual(assetTransferQR?.address, "ABC123")
        XCTAssertEqual(assetTransferQR?.amount, 1000)
        XCTAssertEqual(assetTransferQR?.note, "hello")
        
        let addContactURL = URL(string: "perawallet://app/add-contact/?address=XYZ789&label=MyContact")!
        let addContactQR = DeeplinkQR(url: addContactURL).qrText()
        
        XCTAssertNotNil(addContactQR)
        XCTAssertEqual(addContactQR?.mode, .addContact)
        XCTAssertEqual(addContactQR?.address, "XYZ789")
        XCTAssertEqual(addContactQR?.label, "MyContact")
        
        let buyURL = URL(string: "perawallet://app/buy/?address=BUY123")!
        let buyQR = DeeplinkQR(url: buyURL).qrText()
        
        XCTAssertNotNil(buyQR)
        XCTAssertEqual(buyQR?.mode, .buy)
        XCTAssertEqual(buyQR?.address, "BUY123")
    }
    
    func testLegacyDeeplinkParsing() {
        let legacyAddressURL = URL(string: "perawallet://ABC123?label=TestLabel")!
        let legacyAddressQR = DeeplinkQR(url: legacyAddressURL).qrText()
        
        XCTAssertNotNil(legacyAddressQR)
        XCTAssertEqual(legacyAddressQR?.mode, .address)
        XCTAssertEqual(legacyAddressQR?.address, "ABC123")
        XCTAssertEqual(legacyAddressQR?.label, "TestLabel")
        
        let legacyAlgoURL = URL(string: "perawallet://XYZ789?amount=5000&note=payment")!
        let legacyAlgoQR = DeeplinkQR(url: legacyAlgoURL).qrText()
        
        XCTAssertNotNil(legacyAlgoQR)
        XCTAssertEqual(legacyAlgoQR?.mode, .algosRequest)
        XCTAssertEqual(legacyAlgoQR?.address, "XYZ789")
        XCTAssertEqual(legacyAlgoQR?.amount, 5000)
        XCTAssertEqual(legacyAlgoQR?.note, "payment")
        
        let legacyAssetURL = URL(string: "perawallet://DEF456?amount=100&asset=31566704&xnote=locked")!
        let legacyAssetQR = DeeplinkQR(url: legacyAssetURL).qrText()
        
        XCTAssertNotNil(legacyAssetQR)
        XCTAssertEqual(legacyAssetQR?.mode, .assetRequest)
        XCTAssertEqual(legacyAssetQR?.address, "DEF456")
        XCTAssertEqual(legacyAssetQR?.amount, 100)
        XCTAssertEqual(legacyAssetQR?.asset, 31566704)
        XCTAssertEqual(legacyAssetQR?.lockedNote, "locked")
    }
    
    func testSpecialHostBasedDeeplinks() {
        let discoverURL = URL(string: "perawallet://discover?path=main/markets")!
        let discoverQR = DeeplinkQR(url: discoverURL).qrText()
        
        XCTAssertNotNil(discoverQR)
        XCTAssertEqual(discoverQR?.mode, .discoverPath)
        XCTAssertEqual(discoverQR?.path, "main/markets")
        
        let discoverNoPathURL = URL(string: "perawallet://discover")!
        let discoverNoPathQR = DeeplinkQR(url: discoverNoPathURL).qrText()
        
        XCTAssertNotNil(discoverNoPathQR)
        XCTAssertEqual(discoverNoPathQR?.mode, .discoverPath)
        XCTAssertNil(discoverNoPathQR?.path)
        
        let cardsURL = URL(string: "perawallet://cards?path=rewards/staking")!
        let cardsQR = DeeplinkQR(url: cardsURL).qrText()
        
        XCTAssertNotNil(cardsQR)
        XCTAssertEqual(cardsQR?.mode, .cardsPath)
        XCTAssertEqual(cardsQR?.path, "rewards/staking")
        
        let stakingURL = URL(string: "perawallet://staking?path=validators/list")!
        let stakingQR = DeeplinkQR(url: stakingURL).qrText()
        
        XCTAssertNotNil(stakingQR)
        XCTAssertEqual(stakingQR?.mode, .stakingPath)
        XCTAssertEqual(stakingQR?.path, "validators/list")
    }
    
    func testQueryOnlyDeeplinks() {
        let browserURL = URL(string: "perawallet://?url=https://example.com")!
        let browserQR = DeeplinkQR(url: browserURL).qrText()
        
        XCTAssertNotNil(browserQR)
        XCTAssertEqual(browserQR?.mode, .discoverBrowser)
        XCTAssertEqual(browserQR?.url, "https://example.com")
        
        let optInURL = URL(string: "perawallet://?amount=0&asset=31566704")!
        let optInQR = DeeplinkQR(url: optInURL).qrText()
        
        XCTAssertNotNil(optInQR)
        XCTAssertEqual(optInQR?.mode, .optInRequest)
        XCTAssertEqual(optInQR?.amount, 0)
        XCTAssertEqual(optInQR?.asset, 31566704)
    }
    
    func testUniversalLinkParsing() {
        let universalLinkURL = URL(string: "https://perawallet.app/qr/perawallet/ABC123?amount=1000&note=hello")!
        let universalLinkQR = DeeplinkQR(url: universalLinkURL).qrText()
        
        XCTAssertNotNil(universalLinkQR)
        XCTAssertEqual(universalLinkQR?.mode, .algosRequest)
        XCTAssertEqual(universalLinkQR?.address, "ABC123")
        XCTAssertEqual(universalLinkQR?.amount, 1000)
        XCTAssertEqual(universalLinkQR?.note, "hello")
    }
    
    func testWalletConnectUrl() {
        let wcURL = URL(string: "wc:test-session@1?bridge=https://bridge.walletconnect.org&key=test-key")!
        let walletConnectUrl = DeeplinkQR(url: wcURL).walletConnectUrl()
        
        XCTAssertNotNil(walletConnectUrl)
        XCTAssertEqual(walletConnectUrl, wcURL)
        
        let regularURL = URL(string: "perawallet://ABC123")!
        let nonWCUrl = DeeplinkQR(url: regularURL).walletConnectUrl()
        
        XCTAssertNil(nonWCUrl)
    }
    
    func testInvalidUrls() {
        let noSchemeURL = URL(string: "ABC123?amount=1000")!
        let noSchemeQR = DeeplinkQR(url: noSchemeURL).qrText()
        
        XCTAssertNil(noSchemeQR)
        
        let unsupportedSchemeURL = URL(string: "unsupported://ABC123?amount=1000")!
        let unsupportedQR = DeeplinkQR(url: unsupportedSchemeURL).qrText()
        
        XCTAssertNil(unsupportedQR)
    }
    
    func testComplexScenarios() {
        let appBasedURL = URL(string: "perawallet://app/asset-transfer/?assetId=31566704&receiverAddress=ABC123&amount=500")!
        let appBasedQR = DeeplinkQR(url: appBasedURL).qrText()
        
        XCTAssertNotNil(appBasedQR)
        XCTAssertEqual(appBasedQR?.mode, .assetRequest)
        XCTAssertEqual(appBasedQR?.address, "ABC123")
        XCTAssertEqual(appBasedQR?.amount, 500)
        XCTAssertEqual(appBasedQR?.asset, 31566704)
        
        let keyregURL = URL(string: "perawallet://ABC123?type=keyreg&fee=2000000&selkey=test-sel&votekey=test-vote&votefst=1300&votelst=11300")!
        let keyregQR = DeeplinkQR(url: keyregURL).qrText()
        
        XCTAssertNotNil(keyregQR)
        XCTAssertEqual(keyregQR?.mode, .keyregRequest)
        XCTAssertEqual(keyregQR?.address, "ABC123")
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.fee, 2000000)
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.selectionKey, "test-sel")
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.votingKey, "test-vote")
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.voteFirst, 1300)
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.voteLast, 11300)
    }
    
    func testNewEndpoints() {
        let assetDetailURL = URL(string: "perawallet://app/asset-detail/?address=DETAIL123&assetId=31566704")!
        let assetDetailQR = DeeplinkQR(url: assetDetailURL).qrText()
        
        XCTAssertNotNil(assetDetailQR)
        XCTAssertEqual(assetDetailQR?.mode, .assetDetail)
        XCTAssertEqual(assetDetailQR?.address, "DETAIL123")
        XCTAssertEqual(assetDetailQR?.asset, 31566704)
        
        let sellURL = URL(string: "perawallet://app/sell/?address=SELL123")!
        let sellQR = DeeplinkQR(url: sellURL).qrText()
        
        XCTAssertNotNil(sellQR)
        XCTAssertEqual(sellQR?.mode, .sell)
        XCTAssertEqual(sellQR?.address, "SELL123")
        
        let accountDetailURL = URL(string: "perawallet://app/account-detail/?address=ACCOUNT123")!
        let accountDetailQR = DeeplinkQR(url: accountDetailURL).qrText()
        
        XCTAssertNotNil(accountDetailQR)
        XCTAssertEqual(accountDetailQR?.mode, .accountDetail)
        XCTAssertEqual(accountDetailQR?.address, "ACCOUNT123")
    }
}
