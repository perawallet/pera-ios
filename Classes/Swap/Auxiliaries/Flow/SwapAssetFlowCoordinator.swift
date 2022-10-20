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

//   SwapAssetFlowCoordinator.swift

import Foundation
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class SwapAssetFlowCoordinator:
    SwapIntroductionAlertItemDelegate {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var displayStore = SwapDisplayStore()

    private lazy var swapIntroductionAlertItem = SwapIntroductionAlertItem(delegate: self)
    private lazy var alertTransitionToSwapIntroduction = AlertUITransition(presentingViewController: visibleScreen)
    private lazy var transitionToSignWithLedger = BottomSheetTransition(presentingViewController: visibleScreen)
    private lazy var transitionToSlippageToleranceInfo = BottomSheetTransition(presentingViewController: visibleScreen)
    private lazy var transitionToPriceImpactInfo = BottomSheetTransition(presentingViewController: visibleScreen)

    private var visibleScreen: UIViewController {
        return presentingScreen.findVisibleScreen()
    }

    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private unowned let presentingScreen: UIViewController
    private let account: Account?
    private let asset: Asset?

    init(
        analytics: ALGAnalytics,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        presentingScreen: UIViewController,
        account: Account? = nil,
        asset: Asset? = nil
    ) {
        self.analytics = analytics
        self.api = api
        self.sharedDataController = sharedDataController
        self.presentingScreen = presentingScreen
        self.account = account
        self.asset = asset
    }
}

extension SwapAssetFlowCoordinator {
    func launch() {
        if !displayStore.isOnboardedToSwap {
            displayStore.isOnboardedToSwap = true

            notifyIsOnboardedToSwapObservers()
        }


        if swapIntroductionAlertItem.canBeDisplayed() {
            openSwapIntroductionAlert()
            return
        }

        if !displayStore.isConfirmedSwapUserAgreement {
            openSwapIntroduction()
            return
        }

        startSwapFlow()
    }
}

extension SwapAssetFlowCoordinator {
    private func notifyIsOnboardedToSwapObservers() {
        NotificationCenter.default.post(
            name: SwapDisplayStore.isOnboardedToSwapNotification,
            object: nil
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapIntroductionAlert() {
        alertTransitionToSwapIntroduction.perform(
            .alert(alert: swapIntroductionAlertItem.makeAlert()),
            by: .presentWithoutNavigationController
        )
    }

    private func openSwapIntroduction() {
        let draft = SwapIntroductionDraft(provider: .tinyman)

        let screen = Screen.swapIntroduction(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performPrimaryAction:
                self.displayStore.isConfirmedSwapUserAgreement = true

                self.dismissSwapIntroduction()
                self.startSwapFlow()
            case .performCloseAction:
                self.dismissSwapIntroduction()
            }
        }

        visibleScreen.open(
            screen,
            by: .present
        )
    }

    private func dismissSwapIntroduction() {
        visibleScreen.dismiss(animated: true)
    }
}

extension SwapAssetFlowCoordinator {
    private func startSwapFlow() {
        if let account = account {
            openSwapAsset(from: account)
            return
        }

        openSelectAccount()
    }
}

extension SwapAssetFlowCoordinator {
    private func openSelectAccount() {
        /// <todo> Update after implementing new account selection structure
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapAsset(
        from account: Account
    ) {
        let transactionSigner = SwapTransactionSigner(
            api: api,
            analytics: analytics
        )
        let swapController = PERASwapController(
            account: account,
            userAsset: asset ?? account.algo,
            api: api,
            transactionSigner: transactionSigner
        )

        let swapAssetScreen = visibleScreen.open(
            .swapAsset(
                swapController: swapController,
                coordinator: self
            ),
            by: .present
        ) as? SwapAssetScreen

        swapAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapSwap:
                self.openConfirmAsset(swapController)
            case .didTapUserAsset:
                self.openUserAssetSelection(swapController)
            case .didTapPoolAsset:
                self.openPoolAssetSelection(swapController)
            }
        }
    }

    private func openConfirmAsset(
        _ swapController: SwapController
    ) {
        let dataController = ConfirmSwapAPIDataController(
            swapController: swapController,
            api: api
        )

        let eventHandler: ConfirmSwapScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapConfirm:
                self.openSwapLoadingScren(swapController)
            case .didTapPriceImpactInfo:
                self.openPriceImpactInfo()
            case .didTapSlippageInfo:
                self.openSlippageToleranceInfo()
            case .didTapSlippageAction:
                break
            case .didTapExchangeFeeInfo:
                self.openExchangeFeeInfo()
            }
        }

        visibleScreen.open(
            .confirmSwap(dataController: dataController, eventHandler: eventHandler),
            by: .push
        )
    }

    private func openSwapLoadingScren(
        _ swapController: SwapController
    ) {
        let viewModel = SwapAssetLoadingScreenViewModel(swapController.quote!)
        let swapLoadingScreen = visibleScreen.open(
            .loading(viewModel: viewModel),
            by: .push
        ) as? LoadingScreen

        swapLoadingScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willStartLoading:
                break
            case .didStartLoading:
                /// <todo> Will be changed after the swap signing is completed.
                asyncMain(afterDuration: 5.0) {
                    [weak self] in
                    guard let self = self else { return }
                    self.openSwapSuccessScreen(swapController)
                }
            case .didStopLoading:
                break
            }
        }
    }

    private func openSwapSuccessScreen(
        _ swapController: SwapController
    ) {
        let swapSuccessScreen = visibleScreen.open(
            .swapSuccess(swapController: swapController),
            by: .push
        ) as? SwapAssetSuccessScreen

        swapSuccessScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapViewDetailAction:
                break
            case .didTapDoneAction:
                self.visibleScreen.dismissScreen()
            case .didTapSummaryAction:
                self.openSwapSummaryScreen(swapController)
            }
        }
    }

    private func openSwapSummaryScreen(
        _ swapController: SwapController
    ) {
        visibleScreen.open(
            .swapSummary(swapController: swapController),
            by: .present
        )
    }

    private func openErrorScreen(
        _ swapController: SwapController
    ) {
        let viewModel = SwapUnexpectedErrorViewModel(swapController.quote!)
        let errorScreen = visibleScreen.open(
            .error(viewModel: viewModel),
            by: .present
        ) as? ErrorScreen

        errorScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didTapPrimaryAction:
                break
            case .didTapSecondaryAction:
                self.presentingScreen.dismissScreen()
            }
        }
    }
}

extension SwapAssetFlowCoordinator {
     private func openSignWithLedgerConfirmation(
        totalTransactionCountToSign: Int
     ) {
        let title =
            "swap-sign-with-ledger-title"
                .localized
                .bodyLargeMedium(alignment: .center)
        let highlightedBodyPart =
            "swap-sign-with-ledger-body-highlighted"
                .localized(params: "\(totalTransactionCountToSign)")
        let body =
            "swap-sign-with-ledger-body"
                .localized(params: "\(totalTransactionCountToSign)")
                .bodyRegular(alignment: .center)
                .addAttributes(
                    to: highlightedBodyPart,
                    newAttributes: Typography.bodyMediumAttributes(alignment: .center)
                )

        let uiSheet = UISheet(
            image: "icon-ledger-48",
            title: title,
            body: body
        )

        let signTransactionsAction = UISheetAction(
            title: "swap-sign-with-ledger-action-title".localized,
            style: .default
        ) {
            // <todo> Sign transactions
        }
        uiSheet.addAction(signTransactionsAction)

        transitionToSignWithLedger.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func openSlippageToleranceInfo() {
        let uiSheet = UISheet(
            title: "swap-slippage-tolerance-info-title".localized.bodyLargeMedium(),
            body:"swap-slippage-tolerance-info-body".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.visibleScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToSlippageToleranceInfo.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }

    private func openPriceImpactInfo() {
        let uiSheet = UISheet(
            title: "swap-price-impact-info-title".localized.bodyLargeMedium(),
            body:"swap-price-impact-info-body".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.visibleScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToPriceImpactInfo.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }

    private func openExchangeFeeInfo() {
        let uiSheet = UISheet(
            title: "swap-price-impact-info-title".localized.bodyLargeMedium(),
            body: "swap-confirm-exchange-fee-detail".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.visibleScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToPriceImpactInfo.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func openUserAssetSelection(
        _ swapController: SwapController
    ) {
        let dataController = SelectLocalAssetDataController(
            account: swapController.account,
            api: api,
            sharedDataController: sharedDataController
        )

        let selectAssetScreen = visibleScreen.open(
            .selectAsset(
                dataController: dataController,
                title: "swap-asset-from".localized
            ),
            by: .push
        ) as? SelectAssetScreen

        selectAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectAsset(let asset):
                self.visibleScreen.popScreen()
                self.eventHandler?(.didSelectUserAsset(asset))
            }
        }
    }

    private func openPoolAssetSelection(
        _ swapController: SwapController
    ) {
        let dataController = SelectSwapPoolAssetDataController(
            account: swapController.account,
            userAsset: swapController.userAsset.id,
            swapProvider: swapController.provider,
            api: api,
            sharedDataController: sharedDataController
        )

        let selectAssetScreen = visibleScreen.open(
            .selectAsset(
                dataController: dataController,
                title: "swap-asset-to".localized
            ),
            by: .push
        ) as? SelectAssetScreen

        selectAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectAsset(let asset):
                self.visibleScreen.popScreen()
                self.eventHandler?(.didSelectPoolAsset(asset))
            }
        }
    }
}

extension SwapAssetFlowCoordinator {
    func swapIntroductionAlertItemDidPerformTrySwap(
        _ item: SwapIntroductionAlertItem
    ) {
        item.isDisplayed = true

        visibleScreen.dismiss(animated: true) {
            [unowned self] in
            self.openSwapIntroduction()
        }
    }

    func swapIntroductionAlertItemDidPerformLaterAction(
        _ item: SwapIntroductionAlertItem
    ) {
        item.isDisplayed = true

        visibleScreen.dismiss(animated: true)
    }
}

extension SwapAssetFlowCoordinator {
    enum Event {
        case didSelectUserAsset(Asset)
        case didSelectPoolAsset(Asset)
    }
}
