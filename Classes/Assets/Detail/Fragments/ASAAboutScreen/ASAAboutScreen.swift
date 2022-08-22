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
    private lazy var descriptionView = ShowMoreView()
    private lazy var socialMediaGroupedListView = GroupedListItemButton()
    private lazy var asaReportView = ListItemButton()

    private lazy var transitionToTotalSupply = BottomSheetTransition(presentingViewController: self)

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var mailComposer = MailComposer()

    private var asset: Asset

    private var isShowMoreVisible: Bool = true

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
        bindSectionsData()
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

        addSections()
    }

    private func addSections() {
        let sections = Section.ordered(by: asset)

        for section in sections {
            switch section {
            case .statistics: addStatistics()
            case .about: break
            case .verificationTier: addVerificationTier()
            case .description: addDescription()
            case .socialMediaLinks: addSocialMediaLinks()
            case .report: addAsaReport()
            }
        }
    }

    private func bindSectionsData() {
        let sections = Section.ordered(by: asset)

        for (index, section) in sections.enumerated() {
            switch section {
            case .statistics:
                bindStatisticsData()
            case .about:
                break
            case .verificationTier:
                if verificationTierView.isDescendant(of: contextView) {
                    bindVerificationTierData()
                } else {
                    addVerificationTier(atIndex: index)
                }
            case .description:
                if descriptionView.isDescendant(of: contextView) {
                    bindDescriptionData()
                } else {
                    addDescription(atIndex: index)
                }
            case .socialMediaLinks:
                break
            case .report:
                break
            }
        }
    }

    private func removeSections() {
        contextView.deleteAllSubviews()
    }

    private func addStatistics() {
        statisticsView.customize(theme.statistics)

        contextView.addArrangedSubview(statisticsView)

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: statisticsView,
            margin: theme.spacingBetweenStatisticsAndSeparator
        )

        bindStatisticsData()
    }

    private func bindStatisticsData() {
        let viewModel = AssetStatisticsSectionViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        statisticsView.bindData(viewModel)
    }

    private func addVerificationTier(atIndex index: Int? = nil) {
        verificationTierView.customize(theme.verificationTier)

        contextView.insertArrangedSubview(
            verificationTierView,
            preferredAt: index
        )
        contextView.setCustomSpacing(
            theme.spacingBetweenVerificationTierAndSections,
            after: verificationTierView
        )

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: verificationTierView,
            margin: theme.spacingBetweenVerificationTierAndSeparator
        )

        verificationTierView.startObserving(event: .learnMore) {
            [unowned self] in
            self.open(AlgorandWeb.asaVerificationSupport.link)
        }

        bindVerificationTierData()
    }

    private func bindVerificationTierData() {
        let viewModel = AssetVerificationInfoViewModel(asset.verificationTier)
        verificationTierView.bindData(viewModel)
    }

    private func addDescription(atIndex index: Int? = nil) {
        descriptionView.customize(theme.description)

        contextView.insertArrangedSubview(
            descriptionView,
            preferredAt: index
        )

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: descriptionView,
            margin: theme.spacingBetweenDescriptionAndSeparator
        )

        bindDescriptionData()
    }

    private func bindDescriptionData() {
        let viewModel = AssetDescriptionViewModel(asset: asset)
        descriptionView.bindData(viewModel)
    }

    private func addSocialMediaLinks() {
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
        contextView.attachSeparator(
            theme.sectionSeparator,
            to: socialMediaGroupedListView,
            margin: theme.spacingBetweenSocialMediaAndAsaReport
        )

        asaReportView.customize(theme.asaReport)

        contextView.addArrangedSubview(asaReportView)

        asaReportView.addTouch(
            target: self,
            action: #selector(openMailComposer)
        )

        let viewModel = AsaReportListItemButtonViewModel(asset)
        asaReportView.bindData(viewModel)
    }
}

extension ASAAboutScreen {
    func openTotalSupplyInfo() {
        let uiSheet = UISheet(
            title: "title-total-supply".localized.bodyLargeMedium(),
            body: "asset-total-supply-body".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToTotalSupply.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }
}

extension ASAAboutScreen {
    @objc
    private func openMailComposer() {
        mailComposer.present(from: self)
    }
}

extension ASAAboutScreen: MailComposerDelegate {
    func mailComposerDidSent(_ mailComposer: MailComposer) {}
    func mailComposerDidFailed(_ mailComposer: MailComposer) {}
}

extension ASAAboutScreen {
    private enum Section {
        case statistics
        case about
        case verificationTier
        case description
        case socialMediaLinks
        case report

        static func ordered(by asset: Asset) -> [Section] {
            var list: [Section] = []

            if asset.verificationTier.isSuspicious {
                list.append(.verificationTier)
            }

            list.append(.statistics)
//            list.append(.about)

            if !asset.verificationTier.isSuspicious && !asset.verificationTier.isUnverified {
                list.append(.verificationTier)
            }

            if asset.description.unwrapNonEmptyString() != nil {
                list.append(.description)
            }

            list.append(.socialMediaLinks)
            list.append(.report)

            return list
        }
    }
}
