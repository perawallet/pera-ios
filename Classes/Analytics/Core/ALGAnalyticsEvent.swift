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

//   ALGAnalyticsEvent.swift

import Foundation
import MacaroonVendors
import UIKit

protocol ALGAnalyticsEvent:
    AnalyticsEvent,
    ALGAnalyticsParameterRegulator
where
    Self.Name == ALGAnalyticsEventName,
    Self.Metadata == ALGAnalyticsMetadata {}

/// <note>
/// Naming convention:
/// Action-related name should be used, i.e. either showQRCopy (active) or wcSessionApproved (passive)
/// Some providers may not support a name that is too long. For example, in Firebase Analytics, the maximum supported length is 40 characters. Therefore, event names should be adjusted accordingly.
/// Sort:
/// Alphabetical order
enum ALGAnalyticsEventName:
    String,
    AnalyticsEventName {
    case addAsset
    case buyAlgoFromMoonPayCompleted
    case buyCryptoBidaliSelected
    case buyCryptoMeldSelected
    case changeAssetDetail
    case changeCurrency
    case changeLanguage
    case changeNotificationFilter
    case completeTransaction
    case createAccountInHomeScreen
    case discoverSearch
    case discoverAssetBuy
    case discoverAssetSell
    case discoverDappDetail
    case manageAsset
    case onboardCreateAccountNew
    case onboardCreateAccountRecoverAlgo25
    case onboardCreateAccountRecoverOneKey
    case onboardCreateAccountSkip
    case onboardCreateAccountWatch
    case onboardCreateAccountWatchComplete
    case onboardCreateAccountBeginPassphrase
    case onboardCreateAccountCopyPassphrase
    case onboardCreateAccountUnderstandPassphrase
    case onboardCreateAccountVerifyPassphrase
    case onboardCreateAccountVerifyPassphraseComplete
    case onboardCreateAccountSkipCreatePassphrase
    case onboardCreateAccountSkipWritePassphrase
    case onboardCreateAccountSkipRecoverPassphrase
    case onboardCreateAccountVerifiedBuyAlgo
    case onboardCreateAccountVerifiedStart
    case onboardVerifiedSetPinCode
    case onboardVerifiedSetPinCodeCompleted
    case onboardWatchAccountCreateComplete
    case onboardWatchAccountCreateVerified
    case onboardWelcomeScreenAccountCreate
    case onboardWelcomeScreenAccountRecover
    case qrConnectedInHome
    case registerAccount
    case rekeyAccount
    case showAssetDetail
    case showQRCopy
    case showQRShare
    case showQRShareComplete
    case swapAssetFailed
    case swapBannerLater
    case swapBannerTry
    case swapCompleted
    case swapEnterNumbers
    case swapSelectFromToken
    case swapSelectToToken
    case swapFailed
    case tapBarPressedHomeEvent
    case tapBarPressedDiscoverEvent
    case tapBarPressedQuickConnectEvent
    case tapBarPressedNFTsEvent
    case tapBarPressedSettingsEvent
    case tapBarPressedMenuEvent
    case tapBarPressedSwapEvent
    case tapBarPressedStakeEvent
    case tapAssetsInAccountDetail
    case tapAssetInboxInAccountDetail
    case tapAssetInboxInHome
    case tapAlgoPriceMenu
    case tapBrowseDAppsInQuickAction
    case tapBuyAlgoInAccountDetail
    case tapBuyAlgoInBottomsheet
    case tapBuyAlgoInHome
    case tapBuyAlgoInMoonPay
    case tapBuyAlgoInMeld
    case tapBuyAlgoTab
    case tapChartInHome
    case tapCollectiblesInAccountDetail
    case tapConfirmSwap
    case tapDownloadTransactionInHistory
    case tapFilterTransactionInHistory
    case tapGovernanceBanner
    case tapHistoryInAccountDetail
    case tapMoreInAccountDetail
    case tapNftReceive
    case tapNotifictionInHome
    case tapReceiveInDetail
    case tapReceiveTab
    case tapSendInAccountDetail
    case tapSendInDetail
    case tapSendInHome
    case tapSendTab
    case tapSortInHome
    case tapSpotBanner
    case tapSpotBannerCloseButton
    case tapStakeInHome
    case tapStakeInQuickAction
    case tapChartInAccountDetail
    case tapSwapInAccountDetail
    case tapSwapInAlgoDetail
    case tapSwapInHome
    case tapSwapInSwapScreen
    case tapSwapInQuickAction
    case tapQRInHome
    case wcSessionApproved
    case wcSessionDisconnected
    case wcSessionRejected
    case wcTransactionConfirmed
    case wcTransactionDeclined
    case wcTransactionRequestDidAppear
    case wcTransactionRequestDidLoad
    case wcTransactionRequestReceived
    case wcTransactionRequestSDKError
    case wcTransactionRequestValidated
    case tapQRInMenu
    case tapCreateCardInMenu
    case tapGoToCardsInMenu
    case tapNftsInMenu
    case tapTransferInMenu
    case tapBuyAlgoInMenu
    case tapReceiveInMenu
    case tapInviteFriendsInMenu
    case tapCloseInviteFriendsInMenu
    case tapShareInviteFriendsInMenu
}

extension ALGAnalyticsEventName {
    var rawValue: String {
        /// Sort:
        /// Alphabetical order by `rawName`.
        let rawName: String
        switch self {
        case .tapAssetsInAccountDetail: rawName = "accountscr_assets_tap"
        case .tapCollectiblesInAccountDetail: rawName = "accountscr_collectibles_tap"
        case .tapHistoryInAccountDetail: rawName = "accountscr_history_tap"
        case .tapBuyAlgoInAccountDetail: rawName = "acccountscr_buysell_click"
        case .tapSwapInAccountDetail: rawName = "accountscr_swap_click"
        case .tapAssetInboxInAccountDetail: rawName = "accountscr_tapmenu_asset_inbox_tap"
        case .tapSendInAccountDetail: rawName = "accountscr_tapmenu_send_tap"
        case .tapMoreInAccountDetail: rawName = "accountscr_tapmenu_more_tap"
        case .tapSwapInAlgoDetail : rawName = "algoasadetail_swap_click"
        case .showAssetDetail: rawName = "asset_detail_asset"
        case .changeAssetDetail: rawName = "asset_detail_asset_change"
        case .addAsset: rawName = "assetscr_asset_add"
        case .manageAsset: rawName = "assetscr_assets_manage"
        case .swapBannerLater: rawName = "banner_swap_later"
        case .swapBannerTry: rawName = "banner_swap_tryswap"
        case .tapBuyAlgoInBottomsheet: rawName = "bottommenu_algo_buy_tap"
        case .changeCurrency: rawName = "currency_change"
        case .discoverDappDetail: rawName = "discover_dapps_visit_pages"
        case .discoverSearch: rawName = "discover_markets_search"
        case .discoverAssetBuy: rawName = "discover_token_detail_buy"
        case .discoverAssetSell: rawName = "discover_token_detail_sell"
        case .tapGovernanceBanner: rawName = "homescr_visitgovernance"
        case .tapDownloadTransactionInHistory: rawName = "historyscr_transactions_download"
        case .tapFilterTransactionInHistory: rawName = "historyscr_transactions_filter"
        case .createAccountInHomeScreen: rawName = "homescr_account_add"
        case .tapBuyAlgoInHome: rawName = "homescr_buysell_click"
        case .tapNotifictionInHome: rawName = "homescr_notification_tap"
        case .tapSwapInHome: rawName = "homescr_swap_click"
        case .tapSortInHome: rawName = "homescr_sort_tap"
        case .tapStakeInHome: rawName = "homescr_stake_click"
        case .tapSendInHome: rawName = "homescr_send_click"
        case .tapChartInHome: rawName = "homescr_chart_tap"
        case .tapAssetInboxInHome: rawName = "homescr_asset_inbox_tap"
        case .tapQRInHome: rawName = "homescr_qr_scan"
        case .qrConnectedInHome: rawName = "homescr_qr_scan_connected"
        case .changeLanguage: rawName = "language_change"
        case .tapAlgoPriceMenu: rawName = "nftscr_nft_receive"
        case .tapBuyAlgoInMeld: rawName = "meldscr_algo_buy_tap"
        case .tapBuyAlgoInMoonPay: rawName = "moonpayscr_algo_buy_tap"
        case .buyAlgoFromMoonPayCompleted: rawName = "moonpaycom_algo_buy_completed"
        case .tapNftReceive: rawName = "nftscr_nft_receive"
        case .changeNotificationFilter: rawName = "notification_filter_change"
        case .onboardCreateAccountNew: rawName = "onb_createacc_recover"
        case .onboardCreateAccountRecoverAlgo25: rawName = "onb_createacc_recover_25"
        case .onboardCreateAccountRecoverOneKey: rawName = "onb_createacc_recover_24"
        case .onboardCreateAccountBeginPassphrase: rawName = "onb_createacc_pass_begin"
        case .onboardCreateAccountCopyPassphrase: rawName = "onb_createacc_pass_copy"
        case .onboardCreateAccountUnderstandPassphrase: rawName = "onb_createacc_pass_understand"
        case .onboardCreateAccountVerifyPassphrase: rawName = "onb_createacc_pass_verify"
        case .onboardCreateAccountVerifyPassphraseComplete: rawName = "onb_pass_verified_complete"
        case .onboardCreateAccountSkipCreatePassphrase: rawName = "onb_create_pass_skip_tap"
        case .onboardCreateAccountSkipWritePassphrase: rawName = "onb_write_pass_skip_tap"
        case .onboardCreateAccountSkipRecoverPassphrase: rawName = "onb_rev_pass_skip_tap"
        case .onboardCreateAccountVerifiedBuyAlgo: rawName = "onb_createacc_verified_buyalgo"
        case .onboardCreateAccountVerifiedStart: rawName = "onb_createacc_verified_start"
        case .onboardCreateAccountSkip: rawName = "onb_createacc_skip"
        case .onboardCreateAccountWatch: rawName = "onb_createacc_watch"
        case .onboardCreateAccountWatchComplete: rawName = "onb_welcome_watch_complete"
        case .onboardVerifiedSetPinCode: rawName = "onb_verified_setpincode"
        case .onboardVerifiedSetPinCodeCompleted: rawName = "onb_verified_setpincode_completed"
        case .onboardWatchAccountCreateComplete: rawName = "onb_name_wallet_complete"
        case .onboardWatchAccountCreateVerified: rawName = "onb_watchacc_create_verified"
        case .onboardWelcomeScreenAccountCreate: rawName = "onb_welcome_account_create"
        case .onboardWelcomeScreenAccountRecover: rawName = "onb_welcome_account_recover"
        case .registerAccount: rawName = "register"
        case .rekeyAccount: rawName = "rekey"
        case .swapCompleted: rawName = "swapscr_assets_completed"
        case .swapFailed: rawName = "swapscr_assets_failed"
        case .tapConfirmSwap: rawName = "swapscr_assets_confirm"
        case .swapAssetFailed: rawName = "swapscr_assets_failed"
        case .tapSwapInSwapScreen: rawName = "swapscr_assets_swap"
        case .swapEnterNumbers: rawName = "swapscr_enter_amount_tap"
        case .swapSelectFromToken: rawName = "swapscr_select_top_asset_tap"
        case .swapSelectToToken: rawName = "swapscr_select_lower_asset_tap"
        case .tapReceiveInDetail: rawName = "tap_asset_detail_receive"
        case .tapSendInDetail: rawName = "tap_asset_detail_send"
        case .showQRCopy: rawName = "tap_show_qr_copy"
        case .showQRShare: rawName = "tap_show_qr_share"
        case .showQRShareComplete: rawName = "tap_show_qr_share_complete"
        case .tapBarPressedHomeEvent: rawName = "lowermenu_home_tap"
        case .tapBarPressedDiscoverEvent: rawName = "lowermenu_discover_tap"
        case .tapBarPressedQuickConnectEvent: rawName = "lowermenu_pera_tap"
        case .tapBarPressedNFTsEvent: rawName = "lowermenu_nfts_tap"
        case .tapBarPressedSettingsEvent: rawName = "lowermenu_settings_tap"
        case .tapBarPressedMenuEvent: rawName = "lowermenu_menu_tap"
        case .tapBarPressedSwapEvent: rawName = "lowermenu_swap_tap"
        case .tapBarPressedStakeEvent: rawName = "lowermenu_stake_tap"
        case .tapBuyAlgoTab: rawName = "tap_tab_buy_algo"
        case .tapReceiveTab: rawName = "tap_tab_receive"
        case .tapSendTab: rawName = "tap_tab_send"
        case .completeTransaction: rawName = "transaction"
        case .tapBrowseDAppsInQuickAction: rawName = "bottommenu_browse_dapps_tap"
        case .tapStakeInQuickAction: rawName = "bottommenu_stake_tap"
        case .tapSwapInQuickAction: rawName = "quickaction_swap_click"
        case .wcSessionApproved: rawName = "wc_session_approved"
        case .wcSessionDisconnected: rawName = "wc_session_disconnected"
        case .wcSessionRejected: rawName = "wc_session_rejected"
        case .wcTransactionConfirmed: rawName = "wc_transaction_confirmed"
        case .wcTransactionDeclined: rawName = "wc_transaction_declined"
        case .wcTransactionRequestDidAppear: rawName = "wc_transaction_request_DidAppear"
        case .wcTransactionRequestDidLoad: rawName = "wc_transaction_request_DidLoad"
        case .wcTransactionRequestReceived: rawName = "wc_transaction_request_Received"
        case .wcTransactionRequestSDKError: rawName = "wc_transaction_request_SDKError"
        case .wcTransactionRequestValidated: rawName = "wc_transaction_request_Validated"
        case .buyCryptoMeldSelected: rawName = "meldscr_algo_select_wallet_tap"
        case .buyCryptoBidaliSelected: rawName = "bidscr_algo_sell_tap"
        case .tapSpotBanner: rawName = "homescr_banner_click"
        case .tapSpotBannerCloseButton: rawName = "homescr_banner_close_click"
        case .tapChartInAccountDetail: rawName = "accountscr_chart_tap"
        case .tapQRInMenu: rawName = "menuscr_qr_scan"
        case .tapCreateCardInMenu: rawName = "menuscr_create_card_tap"
        case .tapGoToCardsInMenu: rawName = "menuscr_cards_tap"
        case .tapNftsInMenu: rawName = "menuscr_nfts_tap"
        case .tapTransferInMenu: rawName = "menuscr_transfer_tap"
        case .tapBuyAlgoInMenu: rawName = "menuscr_buyalgo_tap"
        case .tapReceiveInMenu: rawName = "menuscr_receive_tap"
        case .tapInviteFriendsInMenu: rawName = "menuscr_invite_friends_tap"
        case .tapCloseInviteFriendsInMenu: rawName = "menuscr_invite_close_tap"
        case .tapShareInviteFriendsInMenu: rawName = "menuscr_invite_share_tap"
        }

        let isTestnet = UIApplication.shared.appConfiguration?.api.isTestNet ?? false
        return isTestnet ? "t_\(rawName)" : rawName
    }
}
