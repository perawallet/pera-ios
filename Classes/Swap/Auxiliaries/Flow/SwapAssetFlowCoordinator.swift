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
import MacaroonUtils
import UIKit

/// <todo>
/// This should be removed after the routing refactor.
final class SwapAssetFlowCoordinator:
    SwapIntroductionAlertItemDelegate,
    SharedDataControllerObserver,
    WeakPublisher {
    var observations: [ObjectIdentifier: WeakObservation] = [:]

    private lazy var displayStore = SwapDisplayStore()
    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var swapIntroductionAlertItem = SwapIntroductionAlertItem(delegate: self)
    private lazy var alertTransitionToSwapIntroduction = AlertUITransition(presentingViewController: visibleScreen)
    private lazy var transitionToSignWithLedger = BottomSheetTransition(
        presentingViewController: visibleScreen,
        interactable: false
    )
    private lazy var transitionToLedgerSigningProcess = BottomSheetTransition(
        presentingViewController: visibleScreen,
        interactable: false
    )
    private lazy var transitionToSlippageToleranceInfo = BottomSheetTransition(presentingViewController: visibleScreen)
    private lazy var transitionToPriceImpactInfo = BottomSheetTransition(presentingViewController: visibleScreen)
    private lazy var transitionToExchangeFeeInfo = BottomSheetTransition(presentingViewController: visibleScreen)
    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: visibleScreen)

    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private var visibleScreen: UIViewController {
        return presentingScreen.findVisibleScreen()
    }

    private let analytics: ALGAnalytics
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController
    private unowned let presentingScreen: UIViewController
    private var account: Account?
    private let asset: Asset?

    init(
        analytics: ALGAnalytics,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        bannerController: BannerController,
        presentingScreen: UIViewController,
        account: Account? = nil,
        asset: Asset? = nil
    ) {
        self.analytics = analytics
        self.api = api
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.presentingScreen = presentingScreen
        self.account = account
        self.asset = asset
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension SwapAssetFlowCoordinator {
    func launch() {
        sharedDataController.add(self)

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
            openSwapAsset(
                from: account,
                by: .present
            )
            return
        }

        openSelectAccount()
    }
}

extension SwapAssetFlowCoordinator {
    private func openSelectAccount() {
        let screen = Screen.swapAccountSelection {
             [unowned self] event, screen in
             switch event {
             case .didSelect(let accountHandle):
                 let account = accountHandle.value
                 let accountBalance = account.algo.amount
                 let minBalance = account.calculateMinBalance()

                 if accountBalance < minBalance {
                     self.openAccountMinBalanceError(
                        for: account,
                        minBalance: minBalance
                     )
                     return
                 }

                 openSwapAsset(
                    from: accountHandle.value,
                    by: .push
                 )
             }
         }

         visibleScreen.open(
             screen,
             by: .present
         )
    }

    private func openAccountMinBalanceError(
        for account: Account,
        minBalance: UInt64
    ) {
        bannerController.presentErrorBanner(
            title: "swap-flow-start-min-balance-error-title".localized,
            message: "swap-flow-start-min-balance-error-detail".localized(
               params: minBalance.toAlgos.toFractionStringForLabel(fraction: account.algo.decimals) ?? ""
            )
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapAsset(
        from account: Account,
        by style: Screen.Transition.Open
    ) {
        let transactionSigner = SwapTransactionSigner(
            api: api,
            analytics: analytics
        )
        let swapController = ALGSwapController(
            account: account,
            userAsset: asset ?? account.algo,
            api: api,
            transactionSigner: transactionSigner
        )

        swapController.eventHandler = {
            [weak self, weak swapController] event in
            guard let self = self,
                  let swapController = swapController else {
                return
            }

            switch event {
            case .didSignTransaction:
                if account.requiresLedgerConnection(),
                   let signWithLedgerProcessScreen = self.signWithLedgerProcessScreen {
                    signWithLedgerProcessScreen.increaseProgress()

                    if signWithLedgerProcessScreen.isProgressFinished {
                        self.visibleScreen.dismissScreen {
                            [weak self] in
                            guard let self = self else { return }

                            self.openSwapLoading(swapController)
                        }
                    }
                }
            case .didCompleteSwap:
                self.openSwapSuccess(swapController)
            case .didFailTransaction(let id):
                break
            case .didFailNetwork(let error):
                break
            case .didCancelTransaction:
                break
            case .didFailSigning(let error):
                break
            case .didLedgerRequestUserApproval(let ledger, let transactionGroups):
                self.openSignWithLedgerProcess(
                    ledger,
                    transactionGroups: transactionGroups
                )
            case .didFinishTiming:
                break
            case .didLedgerReset:
                break
            case .didLedgerRejectSigning:
                break
            }
        }

        let swapAssetScreen = visibleScreen.open(
            .swapAsset(
                swapController: swapController,
                coordinator: self
            ),
            by: style
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
            case .didTapConfirm(let swapTransactionPreparation):
                let transactionGroups = swapTransactionPreparation.transactionGroups
                if swapController.account.requiresLedgerConnection() {
                    self.openSignWithLedgerConfirmation(
                        swapController: swapController,
                        transactionGroups: transactionGroups
                    )
                    return
                }

                swapController.signTransactions(transactionGroups)
                self.openSwapLoading(swapController)
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

    private func openSwapLoading(
        _ swapController: SwapController
    ) {
        guard let quote = swapController.quote else { return }

        let viewModel = SwapAssetLoadingScreenViewModel(
            quote: quote,
            currencyFormatter: currencyFormatter
        )

        visibleScreen.open(
            .loading(viewModel: viewModel),
            by: .push
        )
    }

    private func openSwapSuccess(
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
                self.openSwapSummary(swapController)
            }
        }
    }

    private func openSwapSummary(
        _ swapController: SwapController
    ) {
        visibleScreen.open(
            .swapSummary(swapController: swapController),
            by: .present
        )
    }

    private func openError(
        _ swapController: SwapController,
        viewModel: ErrorScreenViewModel
    ) {
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
        swapController: SwapController,
        transactionGroups: [SwapTransactionGroup]
     ) {
        let totalTransactionCountToSign = transactionGroups.reduce(0, { $0 + $1.transactionsToSign.count })

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
        ) { [weak self] in
            guard let self = self else { return }

            self.visibleScreen.dismissScreen()
            swapController.signTransactions(transactionGroups)
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

    private func openSignWithLedgerProcess(
        _ ledger: String,
        transactionGroups: [SwapTransactionGroup]
    ) {
        if signWithLedgerProcessScreen != nil {
            return
        }

        let totalTransactionCount = transactionGroups.reduce(0, { $0 + $1.transactionsToSign.count })

        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledger,
            totalTransactionCount: totalTransactionCount
        )

        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancelApproval:
                self.visibleScreen.dismissScreen()
            }
        }

        signWithLedgerProcessScreen = transitionToLedgerSigningProcess.perform(
            .swapSignWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
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

        transitionToExchangeFeeInfo.perform(
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
            filter: AssetZeroBalanceFilterAlgorithm(),
            api: api,
            sharedDataController: sharedDataController
        )

        let selectAssetScreen = visibleScreen.open(
            .selectAsset(
                dataController: dataController,
                coordinator: self,
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
                self.publish(.didSelectUserAsset(asset))
            case .didOptInToAsset: break
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
                coordinator: self,
                title: "swap-asset-to".localized
            ),
            by: .push
        ) as? SelectAssetScreen

        selectAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectAsset(let asset):
                if swapController.account.isOptedIn(to: asset.id) {
                    self.visibleScreen.popScreen()
                    self.publish(.didSelectPoolAsset(asset))
                    return
                }

                let assetDecoration = AssetDecoration(asset: asset)
                self.openOptInAsset(
                    assetDecoration,
                    swapController: swapController
                )
            case .didOptInToAsset(let asset):
                self.visibleScreen.popScreen()
                self.publish(.didSelectPoolAsset(asset))
            }
        }
    }

    private func openOptInAsset(
        _ asset: AssetDecoration,
        swapController: SwapController
    ) {
        let account = swapController.account
        let draft = OptInAssetDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove:
                self.visibleScreen.dismissScreen()
                self.publish(.didApproveOptInToAsset(asset))
            case .performClose:
                self.visibleScreen.dismissScreen()
            }
        }

        transitionToOptInAsset.perform(
            screen,
            by: .present
        )
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
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }

    private func updateAccountIfNeeded() {
        guard let account else { return }

        guard let updatedAccount = sharedDataController.accountCollection[account.address] else { return }

        if !updatedAccount.isAvailable { return }

        self.account = updatedAccount.value
    }
}

extension SwapAssetFlowCoordinator {
    func add(
        _ observer: SwapAssetFlowCoordinatorObserver
    ) {
        let id = ObjectIdentifier(observer as AnyObject)
        observations[id] = WeakObservation(observer)
    }

    private func publish(
        _ event: SwapAssetFlowCoordinatorEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.notifyObservers {
                $0.swapAssetFlowCoordinator(
                    self,
                    didPublish: event
                )
            }
        }
    }
}

extension SwapAssetFlowCoordinator {
    final class WeakObservation: WeakObservable {
        weak var observer: SwapAssetFlowCoordinatorObserver?

        init(
            _ observer: SwapAssetFlowCoordinatorObserver
        ) {
            self.observer = observer
        }
    }
}

protocol SwapAssetFlowCoordinatorObserver: AnyObject {
    func swapAssetFlowCoordinator(
        _ swapAssetFlowCoordinator: SwapAssetFlowCoordinator,
        didPublish event: SwapAssetFlowCoordinatorEvent
    )
}

enum SwapAssetFlowCoordinatorEvent {
    case didSelectUserAsset(Asset)
    case didSelectPoolAsset(Asset)
    case didApproveOptInToAsset(AssetDecoration)
}
