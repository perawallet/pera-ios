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
final class SwapAssetFlowCoordinator {
    private lazy var swapAssetFlowStorage = OneTimeDisplayStorage()

    private lazy var alertTransition = AlertUITransition(presentingViewController: presentingScreen)

    private lazy var transitionToSlippageToleranceInfo = BottomSheetTransition(presentingViewController: presentingScreen)

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
        if !swapAssetFlowStorage.isDisplayedOnce(for: .swapAlert) {
            openSwapAlert()
            return
        }

        if !swapAssetFlowStorage.isDisplayedOnce(for: .swapUserAgreement) {
            openSwapIntroduction()
            return
        }

        startSwapFlow()
    }
}

extension SwapAssetFlowCoordinator {
    private func openSwapAlert() {
        let title = "swap-alert-title"
            .localized
            .bodyLargeMedium(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let body = "swap-alert-body"
            .localized
            .footnoteRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let alert = Alert(
            image: "swap-alert-illustration",
            isNewBadgeVisible: true,
            title: title,
            body: body
        )

        let trySwapAction = AlertAction(
            title: "swap-alert-primary-action".localized,
            style: .primary
        ) {
            [weak self] in
            guard let self = self else { return }
            self.swapAssetFlowStorage.setDisplayedOnce(for: .swapAlert)
            self.dismissSwapAlert()
            self.openSwapIntroduction()
        }
        alert.addAction(trySwapAction)

        let laterAction = AlertAction(
            title: "title-later".localized,
            style: .secondary
        ) {
            [weak self] in
            guard let self = self else { return }
            self.swapAssetFlowStorage.setDisplayedOnce(for: .swapAlert)
            self.dismissSwapAlert()
        }
        alert.addAction(laterAction)

        swapAlertScreen = alertTransition.perform(
            .alert(
                alert: alert,
                theme: AlertScreenWithFillingImageTheme()
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func dismissSwapAlert() {
        swapAlertScreen?.dismissScreen()
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
                self.swapAssetFlowStorage.setDisplayedOnce(for: .swapUserAgreement)

                self.dismissSwapIntroduction()
                self.startSwapFlow()
            case .performCloseAction:
                self.dismissSwapIntroduction()
            }
        }

        swapIntroductionScreen = presentingScreen.open(
            screen,
            by: .present
        )
    }

    private func dismissSwapIntroduction() {
        swapIntroductionScreen?.dismissScreen()
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
