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
    private lazy var displayStore = SwapDisplayStore()

    private lazy var swapIntroductionAlertItem = SwapIntroductionAlertItem(delegate: self)
    private lazy var alertTransitionToSwapIntroduction = AlertUITransition(presentingViewController: presentingScreen)
    
    private lazy var transitionToSignWithLedger = BottomSheetTransition(presentingViewController: presentingScreen)
    private lazy var transitionToSlippageToleranceInfo = BottomSheetTransition(presentingViewController: presentingScreen)
    private lazy var transitionToPriceImpactInfo = BottomSheetTransition(presentingViewController: presentingScreen)

    private var swapAlertScreen: AlertScreen?
    private var swapIntroductionScreen: SwapIntroductionScreen?

    private unowned let presentingScreen: UIViewController
    private let account: Account?
    private let asset: Asset?

    init(
        presentingScreen: UIViewController,
        account: Account? = nil,
        asset: Asset? = nil
    ) {
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
}

extension SwapAssetFlowCoordinator {
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

        presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func dismissSwapIntroduction() {
        presentingScreen.dismiss(animated: true)
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

    private func openSelectAccount() {
        /// <todo> Update after implementing new account selection structure
    }

    private func openSwapAsset(
        from account: Account
    ) {
        let draft = SwapAssetScreenDraft(
            account: account,
            asset: asset
        )

        presentingScreen.open(
            .swapAsset(draft: draft),
            by: .present
        )
    }
}

extension SwapAssetFlowCoordinator {
     private func openSignWithLedgerConfirmation(totalTransactionCountToSign: Int) {
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
    func openAssetSelection(
        dataController: SelectAssetDataController,
        title: String,
        _ completion: @escaping (Asset) -> Void
    ) {
        let selectAssetScreen = presentingScreen.open(
            .selectAsset(
                dataController: dataController,
                title: title
            ),
            by: .push
        ) as? SelectAssetScreen

        selectAssetScreen?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectAsset(let asset):
                self.presentingScreen.popScreen()
                completion(asset)
            }
        }
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
            self.presentingScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToSlippageToleranceInfo.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }
}

extension SwapAssetFlowCoordinator {
    private func openPriceImpactInfo() {
        let uiSheet = UISheet(
            title: "swap-price-impact-info-title".localized.bodyLargeMedium(),
            body:"swap-price-impact-info-body".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.presentingScreen.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToPriceImpactInfo.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }
}

extension SwapAssetFlowCoordinator {
    func swapIntroductionAlertItemDidPerformTrySwap(_ item: SwapIntroductionAlertItem) {
        item.isDisplayed = true

        presentingScreen.dismiss(animated: true) {
            [unowned self] in
            self.openSwapIntroduction()
        }
    }

    func swapIntroductionAlertItemDidPerformLaterAction(_ item: SwapIntroductionAlertItem) {
        item.isDisplayed = true

        presentingScreen.dismiss(animated: true)
    }
}

final class SwapDisplayStore: Storable {
    typealias Object = Any

    static var isOnboardedToSwapNotification: Notification.Name {
        .init(rawValue: "isOnboardedToSwap")
    }

    var isOnboardedToSwap: Bool {
        get { userDefaults.bool(forKey: isOnboardedToSwapKey) }
        set {
            userDefaults.set(newValue, forKey: isOnboardedToSwapKey)
            userDefaults.synchronize()
        }
    }

    var isConfirmedSwapUserAgreement: Bool {
        get { userDefaults.bool(forKey: isConfirmedSwapUserAgreementKey) }
        set {
            userDefaults.set(newValue, forKey: isConfirmedSwapUserAgreementKey)
            userDefaults.synchronize()
        }
    }

    private let isOnboardedToSwapKey = "cache.key.swap.isOnboarded"
    private let isConfirmedSwapUserAgreementKey = "cache.key.swap.isConfirmedUserAgreement"
}
