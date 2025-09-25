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
//  QRTextTests.swift

import XCTest

@testable import pera_wallet_core
@testable import pera_staging

class QRTextTests: XCTestCase {

    func testQRTextForAddress() {
        let qrText = QRText(mode: .address, address: "algorandaddressforqr", label: "value")
        XCTAssertEqual(qrText.qrText(), "algorand://algorandaddressforqr?label=value")
    }

    func testQRTextForRequest() {
        let qrText = QRText(mode: .assetRequest, address: "algorandaddressforqr", amount: 123, asset: 11711)
        XCTAssertEqual(qrText.qrText(), "algorand://algorandaddressforqr?amount=123&asset=11711")
    }
    
    func testQRModeEncoding() {
        let addressQR = QRText(mode: .address, address: "ABC123", label: "TestLabel")
        let addressData = try! JSONEncoder().encode(addressQR)
        let decodedAddressQR = try! JSONDecoder().decode(QRText.self, from: addressData)
        
        XCTAssertEqual(decodedAddressQR.mode, .address)
        XCTAssertEqual(decodedAddressQR.address, "ABC123")
        XCTAssertEqual(decodedAddressQR.label, "TestLabel")
        
        let mnemonicQR = QRText(mode: .mnemonic, mnemonic: "abandon abandon abandon")
        let mnemonicData = try! JSONEncoder().encode(mnemonicQR)
        let decodedMnemonicQR = try! JSONDecoder().decode(QRText.self, from: mnemonicData)
        
        XCTAssertEqual(decodedMnemonicQR.mode, .mnemonic)
        XCTAssertEqual(decodedMnemonicQR.mnemonic, "abandon abandon abandon")
    }
    
    func testQRTextAppFormat() {
        let assetTransferQR = QRText(
            mode: .assetRequest,
            address: "ABC123",
            amount: 1000,
            label: "TestLabel",
            asset: 31566704,
            note: "hello",
            lockedNote: "world"
        )
        let appFormat = assetTransferQR.qrTextAppFormat()
        XCTAssertTrue(appFormat.contains("algorand://app/asset-transfer/"))
        XCTAssertTrue(appFormat.contains("receiverAddress=ABC123"))
        XCTAssertTrue(appFormat.contains("amount=1000"))
        XCTAssertTrue(appFormat.contains("assetId=31566704"))
        XCTAssertTrue(appFormat.contains("note=hello"))
        XCTAssertTrue(appFormat.contains("xnote=world"))
        XCTAssertTrue(appFormat.contains("label=TestLabel"))
        
        let addContactQR = QRText(mode: .addContact, address: "XYZ789", label: "MyContact")
        let contactAppFormat = addContactQR.qrTextAppFormat()
        XCTAssertTrue(contactAppFormat.contains("algorand://app/add-contact/"))
        XCTAssertTrue(contactAppFormat.contains("address=XYZ789"))
        XCTAssertTrue(contactAppFormat.contains("label=MyContact"))
        
        let buyQR = QRText(mode: .buy, address: "BUY123")
        let buyAppFormat = buyQR.qrTextAppFormat()
        XCTAssertTrue(buyAppFormat.contains("algorand://app/buy/"))
        XCTAssertTrue(buyAppFormat.contains("address=BUY123"))
        
        let assetDetailQR = QRText(mode: .assetDetail, address: "DETAIL123", asset: 31566704)
        let assetDetailAppFormat = assetDetailQR.qrTextAppFormat()
        XCTAssertTrue(assetDetailAppFormat.contains("algorand://app/asset-detail/"))
        XCTAssertTrue(assetDetailAppFormat.contains("address=DETAIL123"))
        XCTAssertTrue(assetDetailAppFormat.contains("assetId=31566704"))
    }
    
    func testQRTextLegacyFormat() {
        let addressQR = QRText(mode: .address, address: "ABC123", label: "TestLabel")
        let legacyFormat = addressQR.qrTextLegacyFormat()
        XCTAssertTrue(legacyFormat.contains("ABC123"))
        XCTAssertTrue(legacyFormat.contains("label=TestLabel"))
        
        let algoQR = QRText(mode: .algosRequest, address: "XYZ789", amount: 5000, note: "payment")
        let algoLegacyFormat = algoQR.qrTextLegacyFormat()
        XCTAssertTrue(algoLegacyFormat.contains("XYZ789"))
        XCTAssertTrue(algoLegacyFormat.contains("amount=5000"))
        XCTAssertTrue(algoLegacyFormat.contains("note=payment"))
        
        let discoverQR = QRText(mode: .discoverPath, path: "main/markets")
        let discoverLegacyFormat = discoverQR.qrTextLegacyFormat()
        XCTAssertTrue(discoverLegacyFormat.contains("discover"))
        XCTAssertTrue(discoverLegacyFormat.contains("path=main/markets"))
        
        let buyQR = QRText(mode: .buy, address: "BUY123")
        let buyLegacyFormat = buyQR.qrTextLegacyFormat()
        XCTAssertTrue(buyLegacyFormat.contains("BUY123"))
        
        let wcQR = QRText(mode: .walletConnect, walletConnectUrl: "wc:test-session")
        let wcLegacyFormat = wcQR.qrTextLegacyFormat()
        XCTAssertEqual(wcLegacyFormat, "wc:test-session")
    }
    
    func testUniversalLinkAppFormat() {
        let assetTransferQR = QRText(
            mode: .assetRequest,
            address: "ABC123",
            amount: 1000,
            asset: 31566704,
            note: "hello"
        )
        let universalFormat = assetTransferQR.universalLinkAppFormat()
        XCTAssertTrue(universalFormat.contains("https://"))
        XCTAssertTrue(universalFormat.contains("/qr/perawallet/app/asset-transfer/"))
        XCTAssertTrue(universalFormat.contains("receiverAddress=ABC123"))
        XCTAssertTrue(universalFormat.contains("assetId=31566704"))
        
        let sellQR = QRText(mode: .sell, address: "SELL123")
        let sellUniversalFormat = sellQR.universalLinkAppFormat()
        XCTAssertTrue(sellUniversalFormat.contains("https://"))
        XCTAssertTrue(sellUniversalFormat.contains("/qr/perawallet/app/sell/"))
        XCTAssertTrue(sellUniversalFormat.contains("address=SELL123"))
        
        let accountDetailQR = QRText(mode: .accountDetail, address: "ACCOUNT123")
        let accountDetailUniversalFormat = accountDetailQR.universalLinkAppFormat()
        XCTAssertTrue(accountDetailUniversalFormat.contains("https://"))
        XCTAssertTrue(accountDetailUniversalFormat.contains("/qr/perawallet/app/account-detail/"))
        XCTAssertTrue(accountDetailUniversalFormat.contains("address=ACCOUNT123"))
    }
    
    func testQRTextBuildMethod() {
        let basicParams = ["label": "TestLabel"]
        let basicQR = QRText.build(for: "ABC123", with: basicParams)
        
        XCTAssertNotNil(basicQR)
        XCTAssertEqual(basicQR?.mode, .address)
        XCTAssertEqual(basicQR?.address, "ABC123")
        XCTAssertEqual(basicQR?.label, "TestLabel")
        
        let algoParams = ["amount": "1000", "note": "payment"]
        let algoQR = QRText.build(for: "XYZ789", with: algoParams)
        
        XCTAssertNotNil(algoQR)
        XCTAssertEqual(algoQR?.mode, .algosRequest)
        XCTAssertEqual(algoQR?.address, "XYZ789")
        XCTAssertEqual(algoQR?.amount, 1000)
        XCTAssertEqual(algoQR?.note, "payment")
        
        let assetParams = ["amount": "500", "asset": "31566704", "xnote": "locked"]
        let assetQR = QRText.build(for: "DEF456", with: assetParams)
        
        XCTAssertNotNil(assetQR)
        XCTAssertEqual(assetQR?.mode, .assetRequest)
        XCTAssertEqual(assetQR?.address, "DEF456")
        XCTAssertEqual(assetQR?.amount, 500)
        XCTAssertEqual(assetQR?.asset, 31566704)
        XCTAssertEqual(assetQR?.lockedNote, "locked")
        
        let keyregParams = [
            "type": "keyreg",
            "fee": "2000000",
            "selkey": "test-sel",
            "votekey": "test-vote",
            "votefst": "1300",
            "votelst": "11300"
        ]
        let keyregQR = QRText.build(for: "KEYREG123", with: keyregParams)
        
        XCTAssertNotNil(keyregQR)
        XCTAssertEqual(keyregQR?.mode, .keyregRequest)
        XCTAssertEqual(keyregQR?.address, "KEYREG123")
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.fee, 2000000)
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.selectionKey, "test-sel")
        XCTAssertEqual(keyregQR?.keyRegTransactionQRData?.votingKey, "test-vote")
        
        let assetOptInParams = ["type": "asset/opt-in", "asset": "31566704"]
        let assetOptInQR = QRText.build(for: "OPTIN123", with: assetOptInParams)
        
        XCTAssertNotNil(assetOptInQR)
        XCTAssertEqual(assetOptInQR?.mode, .optInRequest)
        XCTAssertEqual(assetOptInQR?.address, "OPTIN123")
        XCTAssertEqual(assetOptInQR?.asset, 31566704)
        
        let assetDetailParams = ["type": "asset/transactions", "asset": "31566704"]
        let assetDetailQR = QRText.build(for: "DETAIL123", with: assetDetailParams)
        
        XCTAssertNotNil(assetDetailQR)
        XCTAssertEqual(assetDetailQR?.mode, .assetDetail)
        XCTAssertEqual(assetDetailQR?.address, "DETAIL123")
        XCTAssertEqual(assetDetailQR?.asset, 31566704)
        
        let assetInboxParams = ["type": "asset-inbox"]
        let assetInboxQR = QRText.build(for: "INBOX123", with: assetInboxParams)
        
        XCTAssertNotNil(assetInboxQR)
        XCTAssertEqual(assetInboxQR?.mode, .assetInbox)
        XCTAssertEqual(assetInboxQR?.address, "INBOX123")
        
        let browserParams = ["url": "https://example.com"]
        let browserQR = QRText.build(for: nil, with: browserParams)
        
        XCTAssertNotNil(browserQR)
        XCTAssertEqual(browserQR?.mode, .discoverBrowser)
        XCTAssertEqual(browserQR?.url, "https://example.com")
        
        let optInNoAddressParams = ["amount": "0", "asset": "31566704"]
        let optInNoAddressQR = QRText.build(for: nil, with: optInNoAddressParams)
        
        XCTAssertNotNil(optInNoAddressQR)
        XCTAssertEqual(optInNoAddressQR?.mode, .optInRequest)
        XCTAssertEqual(optInNoAddressQR?.amount, 0)
        XCTAssertEqual(optInNoAddressQR?.asset, 31566704)
    }
    
    func testQRTextInitialization() {
        let fullQR = QRText(
            mode: .walletConnect,
            address: "TEST123",
            mnemonic: "test mnemonic",
            amount: 1000,
            label: "TestLabel",
            asset: 31566704,
            note: "test note",
            lockedNote: "locked note",
            walletConnectUrl: "wc:test",
            url: "https://example.com",
            path: "test/path"
        )
        
        XCTAssertEqual(fullQR.mode, .walletConnect)
        XCTAssertEqual(fullQR.address, "TEST123")
        XCTAssertEqual(fullQR.mnemonic, "test mnemonic")
        XCTAssertEqual(fullQR.amount, 1000)
        XCTAssertEqual(fullQR.label, "TestLabel")
        XCTAssertEqual(fullQR.asset, 31566704)
        XCTAssertEqual(fullQR.note, "test note")
        XCTAssertEqual(fullQR.lockedNote, "locked note")
        XCTAssertEqual(fullQR.walletConnectUrl, "wc:test")
        XCTAssertEqual(fullQR.url, "https://example.com")
        XCTAssertEqual(fullQR.path, "test/path")
    }
    
    func testAllQRModes() {
        let allModes: [QRMode] = [
            .address, .mnemonic, .algosRequest, .assetRequest, .optInRequest,
            .keyregRequest, .addContact, .editContact, .addWatchAccount,
            .receiverAccountSelection, .addressActions, .recoverAddress,
            .walletConnect, .assetDetail, .assetInbox, .discoverBrowser,
            .discoverPath, .cardsPath, .stakingPath, .buy, .sell, .accountDetail
        ]
        
        for mode in allModes {
            let qr = QRText(mode: mode, address: "TEST123")
            let data = try! JSONEncoder().encode(qr)
            let decoded = try! JSONDecoder().decode(QRText.self, from: data)
            
            XCTAssertNotNil(decoded)
        }
    }
}
