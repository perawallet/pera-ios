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
    private lazy var aboutView = AssetAboutSectionView()
    private lazy var verificationTierView = AssetVerificationInfoView()
    private lazy var showMoreView = ShowMoreView()
    private lazy var socialMediaGroupedListView = GroupedListItemButton()
    private lazy var asaReportView = ListItemButton()

    private lazy var transitionToTotalSupply = BottomSheetTransition(presentingViewController: self)

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var mailComposer = MailComposer()

    private var asset: Asset
    private let copyToClipboardController: CopyToClipboardController

    private var isShowMoreVisible: Bool = true

    private let theme = ASAAboutScreenTheme()

    init(
        asset: Asset,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.copyToClipboardController = copyToClipboardController
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
            $0.bottom <= 0 + theme.contextEdgeInsets.bottom + view.safeAreaBottom
            $0.trailing == 0 + theme.contextEdgeInsets.trailing
        }

        addStatistics()
        addAbout()
        addVerificationTier()
        addShowMore()
        addSocialMediaGroupedList()
        addASAReportIfNeeded()
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

        statisticsView.startObserving(event: .showTotalSupplyInfo) {
            [unowned self] in
            self.openTotalSupplyInfo()
        }
    }

    private func addAbout() {
        aboutView.customize(theme.about)

        contextView.addArrangedSubview(aboutView)

        let viewModel = AssetAboutSectionViewModel(asset: asset)
        composeAboutItems(for: viewModel)

        aboutView.bindData(viewModel)
    }

    private func addVerificationTier() {
        verificationTierView.customize(theme.verificationTier)

        contextView.addArrangedSubview(verificationTierView)
        contextView.setCustomSpacing(
            theme.spacingBetweenAboutAndVerificationTier,
            after: aboutView
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

        bindVerificationTier()
    }

    private func bindVerificationTier() {
        let viewModel = AssetVerificationInfoViewModel(asset.verificationTier)
        verificationTierView.bindData(viewModel)
    }

    private func addShowMore() {
        guard let standardAsset = asset as? StandardAsset,
              let description = standardAsset.description,
              !description.isEmptyOrBlank else {
            return
        }

        let frameWidth = view.frame.size.width
        let contextHorizontalEdgeInset = theme.contextEdgeInsets.leading + theme.contextEdgeInsets.trailing
        let width = frameWidth - contextHorizontalEdgeInset

        showMoreView.customize(theme.description)
        contextView.addArrangedSubview(showMoreView)

        let draft = ShowMoreDraft(
            title: "collectible-detail-description".localized,
            detail: description,
            allowedNumberOfLines: .custom(4)
        )
        let viewModel = ShowMoreViewModel(
            draft,
            width: width
        )
        showMoreView.bindData(viewModel)
        contextView.attachSeparator(
            theme.sectionSeparator,
            to: showMoreView,
            margin: theme.spacingBetweenVerificationTierAndSeparator
        )
        showMoreView.startObserving(event: .show) {
            let draft = ShowMoreDraft(
                title: "collectible-detail-description".localized,
                detail: description,
                allowedNumberOfLines: self.isShowMoreVisible ? .full : .custom(4)
            )

            let viewModel = ShowMoreViewModel(
                draft,
                width: width
            )
            self.showMoreView.bindData(viewModel)

            self.isShowMoreVisible.toggle()
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

    private func addASAReportIfNeeded() {
        if asset.verificationTier != .suspicious { return }

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
    private func openTotalSupplyInfo() {
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
    private func composeAboutItems(
        for viewModel: AssetAboutSectionViewModel
    ) {
        if asset.isAlgo {
            addAlgoAboutItems(to: viewModel)
            return
        }

        addAssetAboutItems(to: viewModel)
    }

    private func addAlgoAboutItems(
        to viewModel: AssetAboutSectionViewModel
    ) {
        addASAURLItemIfNeeded(to: viewModel)
    }

    private func addAssetAboutItems(
        to viewModel: AssetAboutSectionViewModel
    ) {
        addASAIDItem(to: viewModel)
        addASACreatorItemIfNeeded(to: viewModel)
        addASAURLItemIfNeeded(to: viewModel)
        addASAExplorerURLIfNeeded(to: viewModel)
        addASAProjectWebsiteIfNeeded(to: viewModel)
    }

    private func addASAIDItem(to viewModel: AssetAboutSectionViewModel) {
        var handlers = AssetAboutSectionItem.Handlers()
        handlers.didLongPressAccessory = {
            [unowned self] in
            self.copyToClipboardController.copyID(self.asset)
        }

        viewModel.addItem(
            AssetAboutSectionItem(
                viewModel: ASAAboutScreenASAIDSecondaryListItemViewModel(asset: asset),
                theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
                handlers: handlers
            )
        )
    }

    private func addASACreatorItemIfNeeded(to viewModel: AssetAboutSectionViewModel) {
        if let creator = asset.creator {
            var handlers = AssetAboutSectionItem.Handlers()
            handlers.didTapAccessory = {
                [unowned self] in
                let source = AlgoExplorerExternalSource(
                    address: creator.address,
                    network: self.api!.network
                )

                self.open(source.url)
            }
            handlers.didLongPressAccessory = {
                [unowned self] in
                self.copyToClipboardController.copyAddress(creator.address)
            }

            viewModel.addItem(
                AssetAboutSectionItem(
                    viewModel: ASAAboutScreenASACreatorSecondaryListItemViewModel(asset: asset),
                    theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
                    handlers: handlers
                )
            )
        }
    }

    private func addASAURLItemIfNeeded(to viewModel: AssetAboutSectionViewModel) {
        if let urlString = asset.url {
            var handlers = AssetAboutSectionItem.Handlers()
            handlers.didLongPressAccessory = {
                [unowned self] in
                self.copyToClipboardController.copyURL(urlString)
            }
            handlers.didTapAccessory = {
                [unowned self] in
                self.open(URL(string: urlString))
            }

            viewModel.addItem(
                AssetAboutSectionItem(
                    viewModel: ASAAboutScreenASAURLSecondaryListItemViewModel(asset: asset),
                    theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
                    handlers: handlers
                )
            )
        }
    }

    private func addASAExplorerURLIfNeeded(to viewModel: AssetAboutSectionViewModel) {
        if let explorerURL = asset.explorerURL {
            var handlers = AssetAboutSectionItem.Handlers()
            handlers.didTapAccessory = {
                [unowned self] in
                self.open(explorerURL)
            }

            viewModel.addItem(
                AssetAboutSectionItem(
                    viewModel: ASAAboutScreenShowOnSecondaryListItemViewModel(),
                    theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
                    handlers: handlers
                )
            )
        }
    }

    private func addASAProjectWebsiteIfNeeded(to viewModel: AssetAboutSectionViewModel) {
        /// <todo>: Bind asset's `project_url` when it is ready.
        if let projectURL = URL(string: "projectURL TODO") {
            var handlers = AssetAboutSectionItem.Handlers()
            handlers.didTapAccessory = {
                [unowned self] in
                self.open(projectURL)
            }

            viewModel.addItem(
                AssetAboutSectionItem(
                    viewModel: ASAAboutScreenASAProjectWebsiteSecondaryListItemViewModel(),
                    theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
                    handlers: handlers
                )
            )
        }
    }
}
