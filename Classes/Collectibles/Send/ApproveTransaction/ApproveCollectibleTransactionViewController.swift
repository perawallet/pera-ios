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

//   ApproveCollectibleTransactionViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class ApproveCollectibleTransactionViewController:
    BaseScrollViewController,
    BottomSheetPresentable,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .confirm: UIControlInteraction(),
        .learnMore: UIControlInteraction()
    ]
    
    private lazy var contextView = UIView()
    private lazy var titleView = Label()
    private lazy var descriptionView = Label()
    private lazy var senderAccountInfoView = CollectibleTransactionInfoView()
    private lazy var toAccountInfoView = CollectibleTransactionInfoView()
    private lazy var transactionFeeInfoView = CollectibleTransactionInfoView()
    private lazy var confirmActionView = MacaroonUIKit.Button()
    private lazy var learnMoreActionView = MacaroonUIKit.Button()

    private let theme: ApproveCollectibleTransactionViewControllerTheme
    private let viewModel: ApproveCollectibleTransactionViewModel

    init(
        configuration: ViewControllerConfiguration,
        viewModel: ApproveCollectibleTransactionViewModel = .init(),
        theme: ApproveCollectibleTransactionViewControllerTheme = .init()
    ) {
        self.viewModel = viewModel
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        build()
        bind()
    }

    private func build() {
        addBackground()
        addContent()
    }

    private func bind() {
        senderAccountInfoView.bindData(viewModel.senderAccountViewModel)
        toAccountInfoView.bindData(viewModel.toAccountViewModel)
        transactionFeeInfoView.bindData(viewModel.transactionFeeViewModel)
    }
}

extension ApproveCollectibleTransactionViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContent() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.setPaddings(theme.contentEdgeInsets)
        }

        addTitle()
        addDescription()
        addSenderAccount()
        addToAccount()
        addTransactionFee()
        addConfirmAction()
        addLearnMoreAction()
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contextView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == 0
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contextView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == titleView.snp.bottom + theme.descriptionTopMargin
        }
    }

    private func addSenderAccount() {
        senderAccountInfoView.customize(theme.info)

        contextView.addSubview(senderAccountInfoView)

        let topSeparator = addSeparator(
            to: descriptionView,
            margin: theme.spacingBetweenDescriptionAndSeparator
        )

        senderAccountInfoView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenInfoAndSeparator
        }
    }

    private func addToAccount() {
        toAccountInfoView.customize(theme.info)

        let topSeparator = addSeparator(
            to: senderAccountInfoView,
            margin: theme.spacingBetweenInfoAndSeparator
        )

        contextView.addSubview(toAccountInfoView)

        toAccountInfoView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenInfoAndSeparator
        }
    }

    private func addTransactionFee() {
        transactionFeeInfoView.customize(theme.info)

        let topSeparator = addSeparator(
            to: toAccountInfoView,
            margin: theme.spacingBetweenInfoAndSeparator
        )

        contextView.addSubview(transactionFeeInfoView)

        transactionFeeInfoView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenInfoAndSeparator
        }
    }

    private func addConfirmAction() {
        confirmActionView.customizeAppearance(theme.confirmAction)
        confirmActionView.draw(corner: theme.actionCorner)

        contextView.addSubview(confirmActionView)
        confirmActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        confirmActionView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == transactionFeeInfoView.snp.bottom + theme.confirmActionViewTopPadding
        }

        startPublishing(
            event: .confirm,
            for: confirmActionView
        )
    }

    private func addLearnMoreAction() {
        learnMoreActionView.customizeAppearance(theme.learnMoreAction)
        learnMoreActionView.draw(corner: theme.actionCorner)

        contextView.addSubview(learnMoreActionView)
        learnMoreActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        learnMoreActionView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == confirmActionView.snp.bottom + theme.spacingBetweenActions
            $0.bottom == 0
        }

        startPublishing(
            event: .learnMore,
            for: learnMoreActionView
        )
    }

    private func addSeparator(
        to view: UIView,
        margin: LayoutMetric
    ) -> UIView {
        return contextView.attachSeparator(
            theme.separator,
            to: view,
            margin: margin
        )
    }
}

extension ApproveCollectibleTransactionViewController {
    enum Event {
        case confirm
        case learnMore
    }
}
