// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsasDetailScreen.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import UIKit
import WalletConnectSwift

final class IncomingAsasDetailScreen: BaseViewController {
    
    private lazy var theme = Theme()
    private lazy var incomingAsasDetailView = IncomingAsasDetailView()
    let draft: WCSessionConnectionDraft

    private lazy var footerEffectView = EffectView()
    private lazy var actionsContextView = MacaroonUIKit.HStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var secondaryActionView = MacaroonUIKit.Button()
    private lazy var transitionToRejectConfirmInfo = BottomSheetTransition(presentingViewController: self)

    init(
        draft: WCSessionConnectionDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        super.init(configuration: configuration)
//        startObservingDataUpdates()
    }

    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    
    override func prepareLayout() {
        addIncomingAsasDetailView()
        addActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(with: .black)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isViewFirstLoaded else {
            return
        }
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
    }
    
    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func linkInteractors() {
        incomingAsasDetailView.startObserving(event: .performClose) {
            [weak self] in
            self?.dismissScreen()
        }
    }
}

extension IncomingAsasDetailScreen {
    private func addIncomingAsasDetailView() {
        view.addSubview(incomingAsasDetailView)
        
        incomingAsasDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        let vm = [
            IncomingAsaSenderViewModel.init(amount: "+120.00 USDC", sender: "P5VB…47QY"),
            IncomingAsaSenderViewModel.init(amount: "+60.00 USDC", sender: "hashimov.algo"),
            IncomingAsaSenderViewModel.init(amount: "+70.00 USDC", sender: "L12V…01CN")            
        ]
        incomingAsasDetailView.bindData(

            IncomingAsasDetailViewModel(sourceAccount: draft, senders: vm, id: "12098431")
        )
    }
}

extension IncomingAsasDetailScreen {
    private func addActions() {
        addFooterGradient()
        addActionsContext()
    }

    private func addFooterGradient() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        footerEffectView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(footerEffectView)
        footerEffectView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addActionsContext() {
        footerEffectView.addSubview(actionsContextView)

        actionsContextView.spacing = theme.spacingBetweenActions

        actionsContextView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.actionMargins.bottom

            $0.top == theme.spacingBetweenListAndPrimaryAction
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
            $0.bottom == bottom
        }

        addSecondaryAction()
        addPrimaryAction()
    }

    private func addSecondaryAction() {
        secondaryActionView.customizeAppearance(theme.secondaryAction)

        footerEffectView.addSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)

        actionsContextView.addArrangedSubview(secondaryActionView)

        secondaryActionView.addTouch(
            target: self,
            action: #selector(performSecondaryAction)
        )
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionsContextView.addArrangedSubview(primaryActionView)

        primaryActionView.snp.makeConstraints {
            $0.width == secondaryActionView * theme.secondaryActionWidthMultiplier
        }
        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )
    }
}

extension IncomingAsasDetailScreen {
    @objc
    private func performPrimaryAction() {
        self.dismissScreen()
    }

    @objc
    private func performSecondaryAction() {
        let uiSheet = UISheet(
            image: img("icon-incoming-asa-error"),
            title: "Rejecting Requests".bodyLargeMedium(alignment: .center),
            body: UISheetBodyTextProvider(text: "If you reject this request, the incoming asset will be permanently removed from circulation. It will not be returned to the sender. Instead, you will receive 0.22 ALGOs upon completion of this irreversible process. Please note that once rejected, the asset cannot be recovered.".bodyRegular(alignment: .center))
        )

        let rejectAction = UISheetAction(
            title: "Reject",
            style: .default
        ) { [unowned self] in
            // TODO:  reject
            self.dismiss(animated: true)
        }
        
        let cancelAction = UISheetAction(
            title: "title-cancel".localized,
            style: .cancel
        ) { [unowned self] in
            self.dismiss(animated: true)
        }
        
        uiSheet.addAction(rejectAction)
        uiSheet.addAction(cancelAction)

        transitionToRejectConfirmInfo.perform(
            .sheetAction(
                sheet: uiSheet,
                theme: UISheetActionScreenImageTheme()
            ),
            by: .presentWithoutNavigationController
        )
    }
}
