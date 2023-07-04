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

//   RekeyConfirmationScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyConfirmationScreen:
    ScrollScreen,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)
    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var bodyView = ALGActiveLabel()
    private lazy var summaryView = RekeyInfoView()
    private lazy var informationContentView = MacaroonUIKit.VStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private let theme: RekeyConfirmationScreenTheme

    private let sourceAccount: Account
    private let authAccount: Account?
    private let newAuthAccount: Account

    init(
        sourceAccount: Account,
        authAccount: Account? = nil,
        newAuthAccount: Account,
        theme: RekeyConfirmationScreenTheme = .init(),
        api: ALGAPI?
    ) {
        self.sourceAccount = sourceAccount
        self.authAccount = authAccount
        self.newAuthAccount = newAuthAccount
        self.theme = theme
        super.init(api: api)
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode = .never
        navigationBarLargeTitleController.title = "ledger-rekey-confirm-title".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func linkInteractors() {
        super.linkInteractors()

        navigationBarLargeTitleController.activate()
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

    /// <mark>
    /// UIScrollViewDelegate
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }
}

extension RekeyConfirmationScreen {
    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addBody()
        addSummary()
        addInformationContent()
        addPrimaryAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        contentView.addSubview( navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(theme.navigationBarEdgeInset)
        }
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == navigationBarLargeTitleView.snp.bottom + theme.spacingBetweenTitleAndBody
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

        let hasAuthAccount = authAccount != nil
        if hasAuthAccount {
            addCurrentlyRekeyed()
        }

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

extension RekeyConfirmationScreen {
    private func addCurrentlyRekeyed() {
        guard let authAccount else { return }

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

extension RekeyConfirmationScreen {
    private func bindBody() {
        let viewModel = RekeyConfirmationBodyViewModel(authAccount: authAccount)

        guard let text = viewModel.text else {
            bodyView.text = nil
            bodyView.attributedText = nil
            return
        }

        if let highlightedText = viewModel.highlightedText {
            let hyperlink: ALGActiveType = .word(highlightedText.text)
            bodyView.attachHyperlink(
                hyperlink,
                to: text,
                attributes: highlightedText.attributes
            ) {
                [unowned self] in
                self.open(AlgorandWeb.rekey.link)
            }

            return
        }

        text.load(in: bodyView)
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

extension RekeyConfirmationScreen {
    @objc
    private func performPrimaryAction() {
        eventHandler?(.performPrimaryAction)
    }
}

extension RekeyConfirmationScreen {
    enum Event {
        case performPrimaryAction
    }
}
