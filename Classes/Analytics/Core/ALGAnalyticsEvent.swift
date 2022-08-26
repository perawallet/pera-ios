// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ALGAnalyticsEvent.swift

import Foundation
import MacaroonVendors
import UIKit

protocol ALGAnalyticsEvent: AnalyticsEvent
where
    Self.Name == ALGAnalyticsEventName,
    Self.Metadata == ALGAnalyticsMetadata {}

/// <note>
/// Naming convention:
/// Action-related name should be used, i.e. either showQRCopy (active) or wcSessionApproved (passive)
/// Sort:
/// Alphabetical order
enum ALGAnalyticsEventName:
    String,
    AnalyticsEventName {
    case addAsset
    case buyAlgoFromMoonpayCompleted
    case changeAssetDetail
    case changeCurrency
    case changeLanguage
    case changeNotificationFilter
    case completeTransaction
    case createAccountInHomeScreen
    case manageAsset
    case onboardCreateAccountNew
    case onboardCreateAccountSkip
    case onboardCreateAccountWatch
    case onboardCreateAccountBeginPassphrase
    case onboardCreateAccountCopyPassphrase
    case onboardCreateAccountUnderstandPassphrase
    case onboardCreateAccountVerifyPassphrase
    case onboardCreateAccountVerifiedBuyAlgo
    case onboardCreateAccountVerifiedStart
    case onboardVerifiedSetPinCode
    case onboardVerifiedSetPinCodeCompleted
    case onboardWatchAccountCreate
    case onboardWatchAccountCreateCompleted
    case onboardWelcomeScreenAccountCreate
    case onboardWelcomeScreenAccountRecover
    case qrConnectedInHome
    case registerAccount
    case rekeyAccount
    case showAssetDetail
    case showQRCopy
    case showQRShare
    case showQRShareComplete
    case tapAssetsInAccountDetail
    case tapAlgoPriceMenu
    case tapBuyAlgoInAccountDetail
    case tapBuyAlgoInBottomsheet
    case tapBuyAlgoInHome
    case tapBuyAlgoInMoonpay
    case tapBuyAlgoTab
    case tapCollectiblesInAccountDetail
    case tapDownloadTransactionInHistory
    case tapFilterTransactionInHistory
    case tapGovernanceBanner
    case tapHistoryInAccountDetail
    case tapNftReceive
    case tapReceiveInDetail
    case tapReceiveTab
    case tapSendInDetail
    case tapSendTab
    case tapQRInHome
    case wcSessionApproved
    case wcSessionDisconnected
    case wcSessionRejected
    case wcTransactionConfirmed
    case wcTransactionDeclined
}

extension ALGAnalyticsEventName {
    var rawValue: String {
        /// Sort:
        /// Alphabetical order by `rawName`.
        let rawName: String
        switch self {
        case .tapAssetsInAccountDetail: rawName = "accountscreen_assets_tap"
        case .tapCollectiblesInAccountDetail: rawName = "accountscreen_collectibles_tap"
        case .tapHistoryInAccountDetail: rawName = "accountscreen_collectibles_tap"
        case .tapBuyAlgoInAccountDetail: rawName = "accountscreen_tapmenu_algo_buy_tap"
        case .showAssetDetail: rawName = "asset_detail_asset"
        case .changeAssetDetail: rawName = "asset_detail_asset_change"
        case .addAsset: rawName = "assetscreen_asset_add"
        case .manageAsset: rawName = "assetscreen_assets_manage"
        case .tapBuyAlgoInBottomsheet: rawName = "bottommenu_algo_buy_tap"
        case .changeCurrency: rawName = "currency_change"
        case .tapGovernanceBanner: rawName = "homescreen_visitgovernance"
        case .tapDownloadTransactionInHistory: rawName = "historyscreen_transactions_download"
        case .tapFilterTransactionInHistory: rawName = "historyscreen_transactions_filter"
        case .createAccountInHomeScreen: rawName = "homescreen_account_add"
        case .tapBuyAlgoInHome: rawName = "homescreen_algo_buy_tap"
        case .tapQRInHome: rawName = "homescreen_qr_scan"
        case .qrConnectedInHome: rawName = "homescreen_qr_scan_connected"
        case .changeLanguage: rawName = "language_change"
        case .tapAlgoPriceMenu: rawName = "menu_tap_algoprice"
        case .tapBuyAlgoInMoonpay: rawName = "moonpayscreen_algo_buy_tap"
        case .buyAlgoFromMoonpayCompleted: rawName = "moonpaycom_algo_buy_completed"
        case .tapNftReceive: rawName = "nftscreen_nft_receive"
        case .changeNotificationFilter: rawName = "notification_filter_change"
        case .onboardCreateAccountNew: rawName = "onboarding_createaccount_new"
        case .onboardCreateAccountBeginPassphrase: rawName = "onboarding_createaccount_passphrase_begin"
        case .onboardCreateAccountCopyPassphrase: rawName = "onboarding_createaccount_passphrase_copypassphrase"
        case .onboardCreateAccountUnderstandPassphrase: rawName = "onboarding_createaccount_passphrase_understand"
        case .onboardCreateAccountVerifyPassphrase: rawName = "onboarding_createaccount_passphrase_verifypassphrase"
        case .onboardCreateAccountVerifiedBuyAlgo: rawName = "onboarding_createaccount_verified_buyalgo"
        case .onboardCreateAccountVerifiedStart: rawName = "onboarding_createaccount_verified_start"
        case .onboardCreateAccountSkip: rawName = "onboarding_createaccount_skip"
        case .onboardCreateAccountWatch: rawName = "onboarding_createaccount_watch"
        case .onboardVerifiedSetPinCode: rawName = "onboarding_verified_setpincode"
        case .onboardVerifiedSetPinCodeCompleted: rawName = "onboarding_verified_setpincode_completed"
        case .onboardWatchAccountCreate: rawName = "onboarding_watchaccount_createawatchaccount"
        case .onboardWatchAccountCreateCompleted: rawName = "onboarding_watchaccount_createawatchaccount_verified"
        case .onboardWelcomeScreenAccountCreate: rawName = "onboarding_welcomescreen_account_create"
        case .onboardWelcomeScreenAccountRecover: rawName = "onboarding_welcomescreen_account_recover"
        case .registerAccount: rawName = "register"
        case .rekeyAccount: rawName = "rekey"
        case .tapReceiveInDetail: rawName = "tap_asset_detail_receive"
        case .tapSendInDetail: rawName = "tap_asset_detail_send"
        case .showQRCopy: rawName = "tap_show_qr_copy"
        case .showQRShare: rawName = "tap_show_qr_share"
        case .showQRShareComplete: rawName = "tap_show_qr_share_complete"
        case .tapBuyAlgoTab: rawName = "tap_tab_buy_algo"
        case .tapReceiveTab: rawName = "tap_tab_receive"
        case .tapSendTab: rawName = "tap_tab_send"
        case .completeTransaction: rawName = "transaction"
        case .wcSessionApproved: rawName = "wc_session_approved"
        case .wcSessionDisconnected: rawName = "wc_session_disconnected"
        case .wcSessionRejected: rawName = "wc_session_rejected"
        case .wcTransactionConfirmed: rawName = "wc_transaction_confirmed"
        case .wcTransactionDeclined: rawName = "wc_transaction_declined"
        }

        let isTestnet = UIApplication.shared.appConfiguration?.api.isTestNet ?? false
        return isTestnet ? "testnet_\(rawName)" : rawName
    }
}
