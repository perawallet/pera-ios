// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedToStandardAccountConfirmationScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyedToStandardAccountConfirmationScreen: ScrollScreen {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var titleView = UILabel()
    private lazy var bodyView = ALGActiveLabel()
    private lazy var summaryView = RekeyInfoView()
    private lazy var informationContentView = MacaroonUIKit.VStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private let theme: RekeyedToStandardAccountConfirmationScreenTheme

    private let sourceAccount: Account
    private let authAccount: Account
    private let newAuthAccount: Account

    init(
        sourceAccount: Account,
        authAccount: Account,
        newAuthAccount: Account,
        theme: RekeyedToStandardAccountConfirmationScreenTheme = .init()
    ) {
        self.sourceAccount = sourceAccount
        self.authAccount = authAccount
        self.newAuthAccount = newAuthAccount
        self.theme = theme
        super.init()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension RekeyedToStandardAccountConfirmationScreen {
    private func addUI() {
        addBackground()
        addTitle()
        addBody()
        addSummary()
        addInformationContent()
        addPrimaryAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopInset
            $0.leading == theme.titleHorizontalEdgeInsets.leading
            $0.trailing == theme.titleHorizontalEdgeInsets.trailing
        }

        bindTitle()
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == theme.bodyHorizontalEdgeInsets.leading
            $0.trailing == theme.bodyHorizontalEdgeInsets.trailing
        }

        bindBody()
    }

    private func addSummary() {
        summaryView.customize(theme.summary)

        contentView.addSubview(summaryView)
        summaryView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndSummary
            $0.leading == theme.summaryHorizontalEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.summaryHorizontalEdgeInsets.trailing
        }

        bindSummary()
    }

    private func addInformationContent() {
        footerView.addSubview(informationContentView)
        informationContentView.spacing = theme.spacingBetweenInformationItems
        informationContentView.snp.makeConstraints {
            $0.top == theme.informationContentEdgeInsets.top
            $0.leading == theme.informationContentEdgeInsets.leading
            $0.trailing == theme.informationContentEdgeInsets.trailing
        }

        addCurrentlyRekeyed()
        addTransactionFee()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets

        footerView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top == informationContentView.snp.bottom + theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.trailing == theme.primaryActionEdgeInsets.trailing
            $0.bottom == theme.primaryActionEdgeInsets.bottom
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        bindPrimaryAction()
    }
}

extension RekeyedToStandardAccountConfirmationScreen {
    private func addCurrentlyRekeyed() {
        let view = SecondaryListItemView()
        let theme = RekeyConfirmationInformationItemCommonTheme()
        view.customize(theme)
        informationContentView.addArrangedSubview(view)

        let viewModel = CurrentlyRekeyedAccountInformationItemViewModel(account: authAccount)
        view.bindData(viewModel)
    }

    private func addTransactionFee() {
        let view = SecondaryListItemView()
        let theme = RekeyConfirmationInformationItemCommonTheme()
        view.customize(theme)
        informationContentView.addArrangedSubview(view)

        let fee = Transaction.Constant.minimumFee
        let viewModel = TransactionFeeSecondaryListItemViewModel(fee: fee)
        view.bindData(viewModel)
    }
}

extension RekeyedToStandardAccountConfirmationScreen {
    private func bindTitle() {
        titleView.attributedText =
            "ledger-rekey-confirm-title"
                .localized
                .titleMedium()
    }

    private func bindBody() {
        let text =
            "rekeyed-to-any-account-confirmation-body"
                .localized
                .bodyRegular()

        let hyperlink: ALGActiveType =
            .word("rekeyed-to-any-account-confirmation-body-highlighted-text".localized)

        var attributes = Typography.bodyMediumAttributes()
        attributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        bodyView.attachHyperlink(
            hyperlink,
            to: text,
            attributes: attributes
        ) {
            [unowned self] in
            self.open(AlgorandWeb.rekey.link)
        }
    }

    private func bindSummary() {
        let viewModel = RekeySummaryInfoViewModel(
            sourceAccount: sourceAccount,
            authAccount: newAuthAccount
        )
        summaryView.bindData(viewModel)
    }

    private func bindPrimaryAction() {
        primaryActionView.editTitle = .string("title-confirm".localized)
    }
}

extension RekeyedToStandardAccountConfirmationScreen {
    @objc
    private func performPrimaryAction() {
        eventHandler?(.performPrimaryAction)
    }
}

extension RekeyedToStandardAccountConfirmationScreen {
    enum Event {
        case performPrimaryAction
    }
}
