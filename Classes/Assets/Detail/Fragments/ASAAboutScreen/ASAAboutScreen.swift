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

    private lazy var currencyFormatter = CurrencyFormatter()

    private var asset: Asset

    private let theme = ASAAboutScreenTheme()

    init(
        asset: Asset,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        super.init(configuration: configuration)
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

extension ASAAboutScreen {
    func bindData(asset: Asset) {
        self.asset = asset
        bindUIData()
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

    private func bindUIData() {
        bindStatistics()
        bindVerificationTier()
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
            $0.bottom <= 0 + theme.contextEdgeInsets.bottom
            $0.trailing == 0 + theme.contextEdgeInsets.trailing
        }

        addStatistics()
        addVerificationTier()
    }

    private func addStatistics() {
        statisticsView.customize(theme.statistics)

        contextView.addArrangedSubview(statisticsView)

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: statisticsView,
            margin: theme.spacingBetweenSectionAndSeparator
        )

        bindStatistics()
    }

    private func bindStatistics() {
        let viewModel = AssetStatisticsSectionViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        statisticsView.bindData(viewModel)
    }

    private func addVerificationTier() {
        verificationTierView.customize(theme.verificationTier)

        contextView.addArrangedSubview(verificationTierView)

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: verificationTierView,
            margin: theme.spacingBetweenVerificationTierAndSeparator
        )

        verificationTierView.startObserving(event: .learnMore) {
            [unowned self] in
            self.open(AlgorandWeb.asaVerificationSupport.link)
        }

        bindVerificationTier()
    }

    private func bindVerificationTier() {
        let viewModel = AssetVerificationInfoViewModel(asset.verificationTier)
        verificationTierView.bindData(viewModel)
    }
}
