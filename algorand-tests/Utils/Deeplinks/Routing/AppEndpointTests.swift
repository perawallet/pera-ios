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
//  AppEndpointTests.swift

import XCTest
@testable import pera_staging
@testable import pera_wallet_core

final class AppEndpointTests: XCTestCase {
    
    func testAssetTransferEndpoint() {
        let algoURL = URL(string: "perawallet://app/asset-transfer/?assetId=0&receiverAddress=ABC123&amount=1000&note=hello&xnote=world&label=test")!
        let algoQR = AppEndpoint.assetTransfer.parseQRText(from: algoURL)
        
        XCTAssertNotNil(algoQR)
        XCTAssertEqual(algoQR?.mode, .algosRequest)
        XCTAssertEqual(algoQR?.address, "ABC123")
        XCTAssertEqual(algoQR?.amount, 1000)
        XCTAssertEqual(algoQR?.note, "hello")
        XCTAssertEqual(algoQR?.lockedNote, "world")
        XCTAssertEqual(algoQR?.label, "test")
        
        let assetURL = URL(string: "perawallet://app/asset-transfer/?assetId=31566704&receiverAddress=XYZ789&amount=500")!
        let assetQR = AppEndpoint.assetTransfer.parseQRText(from: assetURL)
        
        XCTAssertNotNil(assetQR)
        XCTAssertEqual(assetQR?.mode, .assetRequest)
        XCTAssertEqual(assetQR?.address, "XYZ789")
        XCTAssertEqual(assetQR?.amount, 500)
        XCTAssertEqual(assetQR?.asset, 31566704)
    }
    
    func testAssetOptInEndpoint() {
        let url = URL(string: "perawallet://app/asset-opt-in/?assetId=31566704&note=optin&xnote=test")!
        let qr = AppEndpoint.assetOptIn.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .optInRequest)
        XCTAssertEqual(qr?.amount, 0)
        XCTAssertEqual(qr?.asset, 31566704)
        XCTAssertEqual(qr?.note, "optin")
        XCTAssertEqual(qr?.lockedNote, "test")
    }
    
    func testKeyRegEndpoint() {
        let url = URL(string: "perawallet://app/keyreg/?address=ABC123&fee=2000000&selkey=test-sel&sprfkey=test-sprf&votekd=100&votekey=test-vote&votefst=1300&votelst=11300&note=keyreg")!
        let qr = AppEndpoint.keyReg.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .keyregRequest)
        XCTAssertEqual(qr?.address, "ABC123")
        XCTAssertEqual(qr?.note, "keyreg")
        XCTAssertEqual(qr?.keyRegTransactionQRData?.fee, 2000000)
        XCTAssertEqual(qr?.keyRegTransactionQRData?.selectionKey, "test-sel")
        XCTAssertEqual(qr?.keyRegTransactionQRData?.stateProofKey, "test-sprf")
        XCTAssertEqual(qr?.keyRegTransactionQRData?.voteKeyDilution, 100)
        XCTAssertEqual(qr?.keyRegTransactionQRData?.votingKey, "test-vote")
        XCTAssertEqual(qr?.keyRegTransactionQRData?.voteFirst, 1300)
        XCTAssertEqual(qr?.keyRegTransactionQRData?.voteLast, 11300)
    }
    
    func testAddContactEndpoint() {
        let url = URL(string: "perawallet://app/add-contact/?address=ABC123&label=MyContact")!
        let qr = AppEndpoint.addContact.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .addContact)
        XCTAssertEqual(qr?.address, "ABC123")
        XCTAssertEqual(qr?.label, "MyContact")
    }
    
    func testEditContactEndpoint() {
        let url = URL(string: "perawallet://app/edit-contact/?address=XYZ789&label=UpdatedContact")!
        let qr = AppEndpoint.editContact.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .editContact)
        XCTAssertEqual(qr?.address, "XYZ789")
        XCTAssertEqual(qr?.label, "UpdatedContact")
    }
    
    func testAddWatchAccountEndpoint() {
        let url = URL(string: "perawallet://app/add-watch-account/?address=WATCH123&label=WatchAccount")!
        let qr = AppEndpoint.addWatchAccount.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .addWatchAccount)
        XCTAssertEqual(qr?.address, "WATCH123")
        XCTAssertEqual(qr?.label, "WatchAccount")
        
        // Test register-watch-account alias
        let registerURL = URL(string: "perawallet://app/register-watch-account/?address=REGISTER123")!
        let registerQR = AppEndpoint.registerWatchAccount.parseQRText(from: registerURL)
        
        XCTAssertNotNil(registerQR)
        XCTAssertEqual(registerQR?.mode, .addWatchAccount)
        XCTAssertEqual(registerQR?.address, "REGISTER123")
    }
    
    func testReceiverAccountSelectionEndpoint() {
        let url = URL(string: "perawallet://app/receiver-account-selection/?address=RECEIVER123")!
        let qr = AppEndpoint.receiverAccountSelection.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .receiverAccountSelection)
        XCTAssertEqual(qr?.address, "RECEIVER123")
    }
    
    func testAddressActionsEndpoint() {
        let url = URL(string: "perawallet://app/address-actions/?address=ACTION123&label=ActionLabel")!
        let qr = AppEndpoint.addressActions.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .addressActions)
        XCTAssertEqual(qr?.address, "ACTION123")
        XCTAssertEqual(qr?.label, "ActionLabel")
    }
    
    func testRecoverAddressEndpoint() {
        let mnemonic = "abandon,abandon,abandon,abandon,abandon,abandon,abandon,abandon,abandon,abandon,abandon,about"
        let url = URL(string: "perawallet://app/recover-address/?mnemonic=\(mnemonic)")!
        let qr = AppEndpoint.recoverAddress.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .recoverAddress)
        XCTAssertEqual(qr?.mnemonic, mnemonic)
    }
    
    func testWalletConnectEndpoint() {
        let wcUrl = "wc:test-session@1?bridge=bridge&key=key"
        let url = URL(string: "perawallet://app/wallet-connect/?walletConnectUrl=\(wcUrl)")!
        let qr = AppEndpoint.walletConnect.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .walletConnect)
        
        let uriURL = URL(string: "perawallet://app/wallet-connect/?uri=\(wcUrl)")!
        let uriQR = AppEndpoint.walletConnect.parseQRText(from: uriURL)
        
        XCTAssertNotNil(uriQR)
        XCTAssertEqual(uriQR?.mode, .walletConnect)
    }
    
    func testAssetDetailEndpoint() {
        let url = URL(string: "perawallet://app/asset-detail/?address=ASSET123&assetId=31566704")!
        let qr = AppEndpoint.assetDetail.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .assetDetail)
        XCTAssertEqual(qr?.address, "ASSET123")
        XCTAssertEqual(qr?.asset, 31566704)
    }
    
    func testAssetInboxEndpoint() {
        let url = URL(string: "perawallet://app/asset-inbox/?address=INBOX123")!
        let qr = AppEndpoint.assetInbox.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .assetInbox)
        XCTAssertEqual(qr?.address, "INBOX123")
    }
    
    func testDiscoverBrowserEndpoint() {
        let browserUrl = "https://example.com"
        let url = URL(string: "perawallet://app/discover-browser/?url=\(browserUrl)")!
        let qr = AppEndpoint.discoverBrowser.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .discoverBrowser)
        XCTAssertEqual(qr?.url, browserUrl)
    }
    
    func testDiscoverPathEndpoint() {
        let path = "main/markets"
        let url = URL(string: "perawallet://app/discover-path/?path=\(path)")!
        let qr = AppEndpoint.discoverPath.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .discoverPath)
        XCTAssertEqual(qr?.path, path)
        
        let noPathURL = URL(string: "perawallet://app/discover-path/")!
        let noPathQR = AppEndpoint.discoverPath.parseQRText(from: noPathURL)
        
        XCTAssertNotNil(noPathQR)
        XCTAssertEqual(noPathQR?.mode, .discoverPath)
        XCTAssertNil(noPathQR?.path)
    }
    
    func testCardsPathEndpoint() {
        let path = "rewards/staking"
        let url = URL(string: "perawallet://app/cards-path/?path=\(path)")!
        let qr = AppEndpoint.cardsPath.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .cardsPath)
        XCTAssertEqual(qr?.path, path)
    }
    
    func testStakingPathEndpoint() {
        let path = "validators/list"
        let url = URL(string: "perawallet://app/staking-path/?path=\(path)")!
        let qr = AppEndpoint.stakingPath.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .stakingPath)
        XCTAssertEqual(qr?.path, path)
    }
    
    func testBuyEndpoint() {
        let url = URL(string: "perawallet://app/buy/?address=BUY123")!
        let qr = AppEndpoint.buy.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .buy)
        XCTAssertEqual(qr?.address, "BUY123")
    }
    
    func testSellEndpoint() {
        let url = URL(string: "perawallet://app/sell/?address=SELL123")!
        let qr = AppEndpoint.sell.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .sell)
        XCTAssertEqual(qr?.address, "SELL123")
    }
    
    func testAccountDetailEndpoint() {
        let url = URL(string: "perawallet://app/account-detail/?address=ACCOUNT123")!
        let qr = AppEndpoint.accountDetail.parseQRText(from: url)
        
        XCTAssertNotNil(qr)
        XCTAssertEqual(qr?.mode, .accountDetail)
        XCTAssertEqual(qr?.address, "ACCOUNT123")
    }
    
    func testInvalidEndpoints() {
        let invalidAssetTransfer = URL(string: "perawallet://app/asset-transfer/?receiverAddress=ABC123")!
        XCTAssertNil(AppEndpoint.assetTransfer.parseQRText(from: invalidAssetTransfer))
        
        let invalidAssetOptIn = URL(string: "perawallet://app/asset-opt-in/?note=test")!
        XCTAssertNil(AppEndpoint.assetOptIn.parseQRText(from: invalidAssetOptIn))
        
        let invalidKeyReg = URL(string: "perawallet://app/keyreg/?fee=1000")!
        XCTAssertNil(AppEndpoint.keyReg.parseQRText(from: invalidKeyReg))
        
        let invalidContact = URL(string: "perawallet://app/add-contact/?label=test")!
        XCTAssertNil(AppEndpoint.addContact.parseQRText(from: invalidContact))
    }
}
