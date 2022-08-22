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

//   ASAAboutScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASAAboutScreen:
    BaseScrollViewController,
    ASADetailPageFragmentScreen,
    UIScrollViewDelegate {
    var isScrollAnchoredOnTop = true

    private lazy var contextView = VStackView()
    private lazy var statisticsView = AssetStatisticsSectionView()
    private lazy var verificationTierView = AssetVerificationInfoView()
    private lazy var socialMediaGroupedListView = GroupedListItemButton()
    private lazy var asaReportView = ListItemButton()

    private lazy var mailComposer = MailComposer()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let asset: Asset

    private let theme = ASAAboutScreenTheme()

    init(
        asset: Asset,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        super.init(configuration: configuration)

        self.mailComposer.configureMail(for: .report(assetId: asset.id))
    }

    override func linkInteractors() {
        super.linkInteractors()
        mailComposer.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIWhenViewDidLayoutSubviews()
    }
}

/// <mark>
/// UIScrollViewDelegate
extension ASAAboutScreen {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUIWhenViewDidScroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateUIWhenViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}

extension ASAAboutScreen {
    private func addUI() {
        addBackground()
        addContext()

        updateScroll()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateScrollWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenViewDidScroll() {
        updateScrollWhenViewDidScroll()
    }

    private func updateUIWhenViewWillEndDragging(
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateScrollWhenViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func updateScroll() {
        scrollView.delegate = self
    }

    private func addContext() {
        contextView.distribution = .fill
        contextView.alignment = .fill
        contextView.spacing = theme.spacingBetweenSections
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == 0 + theme.contextEdgeInsets.top
            $0.leading == 0 + theme.contextEdgeInsets.leading
            $0.bottom <= 0 + theme.contextEdgeInsets.bottom + view.safeAreaBottom
            $0.trailing == 0 + theme.contextEdgeInsets.trailing
        }

        addStatistics()
        addVerificationTier()
        addSocialMediaGroupedList()

        if asset.verificationTier == .suspicious {
            contextView.attachSeparator(
                theme.sectionSeparator,
                to: socialMediaGroupedListView,
                margin: theme.spacingBetweenSocialMediaAndAsaReport
            )

            addAsaReport()
        }
    }

    private func addStatistics() {
        statisticsView.customize(theme.statistics)

        contextView.addArrangedSubview(statisticsView)

        let viewModel = AssetStatisticsSectionViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        statisticsView.bindData(viewModel)

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: statisticsView,
            margin: theme.spacingBetweenSectionAndSeparator
        )
    }

    private func addVerificationTier() {
        verificationTierView.customize(theme.verificationTier)

        contextView.addArrangedSubview(verificationTierView)

        let viewModel = AssetVerificationInfoViewModel(asset.verificationTier)
        verificationTierView.bindData(viewModel)

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: verificationTierView,
            margin: theme.spacingBetweenVerificationTierAndSeparator
        )

        verificationTierView.startObserving(event: .learnMore) {
            [unowned self] in
            self.open(AlgorandWeb.asaVerificationSupport.link)
        }
    }

    private func addSocialMediaGroupedList() {
        socialMediaGroupedListView.customize(theme.socialMediaGroupedList)

        contextView.addArrangedSubview(socialMediaGroupedListView)

        let viewModel = AssetSocialMediaGroupedListItemButtonViewModel([
            .discord,
            .telegram,
            .twitter
        ])
        socialMediaGroupedListView.bindData(viewModel)
    }

    private func addAsaReport() {
        asaReportView.customize(theme.asaReport)

        contextView.addArrangedSubview(asaReportView)

        let viewModel = AsaReportListItemButtonViewModel(asset)
        asaReportView.bindData(viewModel)

        asaReportView.addTouch(
            target: self,
            action: #selector(openMailComposer)
        )
    }
}

extension ASAAboutScreen: MailComposerDelegate {
    func mailComposerDidSent(_ mailComposer: MailComposer) {}
    func mailComposerDidFailed(_ mailComposer: MailComposer) {}
}

extension ASAAboutScreen {
    @objc
    private func openMailComposer() {
        mailComposer.present(from: self)
    }
}
