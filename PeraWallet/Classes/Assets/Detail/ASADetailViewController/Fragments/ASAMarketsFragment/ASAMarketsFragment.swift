// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ASAMarketsFragment.swift

import UIKit
import pera_wallet_core

final class ASAMarketsFragment:
    BaseScrollViewController,
    UIScrollViewDelegate {
    
    var contentSize: CGSize {
        return CGSize(
            width: contextView.bounds.width,
            height: contextView.frame.maxY
        )
    }

    private lazy var contextView = VStackView()
    private lazy var profileView = ASAProfileView(type: .assetPrice)
    private lazy var marketInfoView = ASADetailMarketView()
    private lazy var statisticsView = AssetStatisticsSectionView()
    private lazy var aboutView = AssetAboutSectionView()
    private lazy var verificationTierView = AssetVerificationInfoView()
    private lazy var descriptionView = ShowMoreView()
    private lazy var socialMediaView = GroupedListItemButton()
    private lazy var reportActionView = ListItemButton()

    private lazy var transitionToTotalSupply = BottomSheetTransition(presentingViewController: self)

    private lazy var currencyFormatter = CurrencyFormatter()
    private lazy var amountFormatter = CollectibleAmountFormatter()
    private lazy var mailComposer = MailComposer()

    private var asset: Asset
    private var account: Account
    private var chartData: ChartViewData?
    private var currency: CurrencyProvider
    private let copyToClipboardController: CopyToClipboardController
    private var eventHandler: ASADetailViewController.EventHandler?

    private let theme = ASAMarketsFragmentTheme()

    init(
        account: Account,
        asset: Asset,
        currency: CurrencyProvider,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration,
        eventHandler: ASADetailViewController.EventHandler?
    ) {
        self.asset = asset
        self.account = account
        self.currency = currency
        self.eventHandler = eventHandler
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindUIData()
    }
}

extension ASAMarketsFragment {
    func bindData(asset: Asset, account: Account, chartData: ChartViewData?) {
        self.asset = asset
        self.account = account
        if let chartData {
            self.chartData = chartData
        }

        if isViewLoaded {
            bindUIData()
        }
    }
}

extension ASAMarketsFragment {
    private func addUI() {
        addBackground()
        addContext()

        updateScroll()
    }

    private func bindUIData() {
        bindSectionsData()
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
            $0.top.equalToSuperview().inset(theme.contextEdgeInsets.top)
            $0.leading.equalToSuperview().inset(theme.contextEdgeInsets.leading)
            $0.trailing.equalToSuperview().inset(theme.contextEdgeInsets.trailing)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.contextEdgeInsets.bottom + view.safeAreaBottom)
        }

        addProfile()
        if asset.isAvailableOnDiscover {
            addMarketInfoView()
        }
        addStatistics()
        addAbout()
    }

    private func bindSectionsData() {
        let sections = Section.ordered(by: asset)

        for (index, section) in sections.enumerated() {
            switch section {
            case .profile:
                bindProfile()
            case .market:
                bindMarketData()
            case .statistics:
                bindStatisticsData()
            case .about:
                bindAboutData()
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
            case .socialMedia:
                if socialMediaView.isDescendant(of: contextView) {
                    bindSocialMediaData()
                } else {
                    addSocialMedia(atIndex: index)
                }
            case .report:
                if reportActionView.isDescendant(of: contextView) {
                    bindReportActionData()
                } else {
                    addReportAction(atIndex: index)
                }
            }
        }
    }
    
    private func addProfile() {
        profileView.customize(theme.profile)

        contextView.addArrangedSubview(profileView)
        contextView.setCustomSpacing(
            theme.spacingBetweenProfileAndMarket,
            after: profileView
        )
        
        bindProfile()
    }

    private func bindProfile() {
        profileView.startObserving(event: .onAmountTap) {
            ObservableUserDefaults.shared.isPrivacyModeEnabled.toggle()
        }
        
        profileView.startObserving(event: .onFavoriteTap) { [weak self] in
            guard let self else { return }
            eventHandler?(.profileOnFavoriteTap)
        }
        
        profileView.startObserving(event: .onNotificationTap) { [weak self] in
            guard let self else { return }
            eventHandler?(.profileOnNotificationTap)
        }

        profileView.onPeriodChange = { [weak self] newPeriodSelected in
            guard let self else { return }
            eventHandler?(.profileOnPeriodChange(account: account, asset: asset, newPeriodSelected: newPeriodSelected))
        }

        profileView.onPointSelected = { [weak self] pointSelected in
            guard let self else { return }

            guard
                let pointSelected,
                let date = pointSelected.timestamp.toDate(.fullNumericWithTimezone) ?? pointSelected.timestamp.toDate(.fullNumericWithTimezoneAndSeconds)
            else {
                bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
                return
            }

            let vm = ChartSelectedPointViewModel(
                algoValue: pointSelected.algoValue,
                fiatValue: pointSelected.fiatValue,
                usdValue: pointSelected.usdValue,
                dateValue: DateFormatter.chartDisplay.string(from: date)
            )
            bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled,
                            chartPointSelected: vm)
        }

        bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
        profileView.updateChart(with: chartData)
    }
    
    private func bindProfileData(isAmountHidden: Bool, chartPointSelected: ChartSelectedPointViewModel? = nil) {
        let priceViewModel = AssetStatisticsSectionPriceViewModel(
            asset: asset,
            currency: currency,
            currencyFormatter: currencyFormatter,
            chartPointSelected: chartPointSelected
        )
        
        let viewModel = ASADetailProfileViewModel(
            asset: asset,
            currency: currency,
            currencyFormatter: CurrencyFormatter(),
            isAmountHidden: isAmountHidden,
            selectedPointVM: chartPointSelected,
            priceVM: priceViewModel
        )

        profileView.bindData(viewModel)
    }
    
    private func addMarketInfoView() {
        marketInfoView.customize(theme.marketInfo)
        
        contextView.addArrangedSubview(marketInfoView)
        contextView.setCustomSpacing(
            theme.spacingBetweenMarketAndStatistics,
            after: marketInfoView
        )

        marketInfoView.startObserving(event: .market) {
            [unowned self] in

            let assetDetail = DiscoverAssetParameters(asset: asset)
            self.open(
                .discoverAssetDetail(assetDetail),
                by: .push
            )
        }

        bindMarketData()
    }
    
    private func bindMarketData() {
        let viewModel = ASADetailMarketViewModel(
            assetItem: .init(
                asset: asset,
                currency: sharedDataController.currency,
                currencyFormatter: CurrencyFormatter(),
                isAmountHidden: false
            )
        )
        marketInfoView.bindData(viewModel)
    }

    private func addStatistics() {
        statisticsView.customize(theme.statistics)

        contextView.addArrangedSubview(statisticsView)
        contextView.setCustomSpacing(
            theme.spacingBetweenStatisticsAndAbout,
            after: statisticsView
        )

        bindStatisticsData()
    }

    private func bindStatisticsData() {
        let viewModel = AssetStatisticsSectionViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter,
            amountFormatter: amountFormatter
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

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: aboutView,
            margin: theme.spacingBetweenSeparatorAndAbout
        )

        bindAboutData()
    }

    private func bindAboutData() {
        if asset.isAlgo {
            bindAlgoAboutData()
        } else {
            bindAssetAboutData()
        }
    }

    private func bindAlgoAboutData() {
        let viewModel = AssetAboutSectionViewModel(asset: asset)

        if asset.url.unwrapNonEmptyString() != nil {
            let item = makeASAURLItem()
            viewModel.addItem(item)
        }

        aboutView.bindData(viewModel)
    }

    private func bindAssetAboutData() {
        let viewModel = AssetAboutSectionViewModel(asset: asset)

        viewModel.addItem(makeASAIDItem())

        if asset.creator != nil {
            let item = makeASACreatorItem()
            viewModel.addItem(item)
        }

        if asset.url.unwrapNonEmptyString() != nil {
            let item = makeASAURLItem()
            viewModel.addItem(item)
        }

        if asset.explorerURL != nil {
            let item = makeASAExplorerURLItem()
            viewModel.addItem(item)
        }

        if asset.projectURL != nil {
            let item = makeASAProjectWebsiteItem()
            viewModel.addItem(item)
        }

        aboutView.bindData(viewModel)
    }

    private func makeASAIDItem() -> AssetAboutSectionItem {
        var handlers = AssetAboutSectionItem.Handlers()
        handlers.didLongPressAccessory = {
            [unowned self] in
            self.copyToClipboardController.copyID(self.asset)
        }
        return AssetAboutSectionItem(
            viewModel: ASAAboutScreenASAIDSecondaryListItemViewModel(asset: asset),
            theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
            handlers: handlers
        )
    }

    private func makeASACreatorItem() -> AssetAboutSectionItem {
        var handlers = AssetAboutSectionItem.Handlers()
        handlers.didTapAccessory = {
            [unowned self] in

            if let address = self.asset.creator?.address {
                let source = PeraExplorerExternalSource(
                    address: address,
                    network: self.api!.network
                )
                self.open(source.url)
            }
        }
        handlers.didLongPressAccessory = {
            [unowned self] in

            if let address = self.asset.creator?.address {
                self.copyToClipboardController.copyAddress(address)
            }
        }
        return AssetAboutSectionItem(
            viewModel: ASAAboutScreenASACreatorSecondaryListItemViewModel(asset: asset),
            theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
            handlers: handlers
        )
    }

    private func makeASAURLItem() -> AssetAboutSectionItem {
        var handlers = AssetAboutSectionItem.Handlers()
        handlers.didLongPressAccessory = {
            [unowned self] in

            if let urlString = self.asset.url {
                self.copyToClipboardController.copyURL(urlString)
            }
        }
        handlers.didTapAccessory = {
            [unowned self] in

            if let urlString = self.asset.url,
               let url = URL(string: urlString) {
                self.open(url)
            }
        }
        return AssetAboutSectionItem(
            viewModel: ASAAboutScreenASAURLSecondaryListItemViewModel(asset: asset),
            theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
            handlers: handlers
        )
    }

    private func makeASAExplorerURLItem() -> AssetAboutSectionItem {
        var handlers = AssetAboutSectionItem.Handlers()
        handlers.didTapAccessory = {
            [unowned self] in

            if let explorerURL = self.asset.explorerURL {
                self.open(explorerURL)
            }
        }
        return AssetAboutSectionItem(
            viewModel: ASAAboutScreenShowOnSecondaryListItemViewModel(),
            theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
            handlers: handlers
        )
    }

    private func makeASAProjectWebsiteItem() -> AssetAboutSectionItem {
        var handlers = AssetAboutSectionItem.Handlers()
        handlers.didTapAccessory = {
            [unowned self] in

            if let projectURL = self.asset.projectURL {
                self.open(projectURL)
            }
        }
        return AssetAboutSectionItem(
            viewModel: ASAAboutScreenASAProjectWebsiteSecondaryListItemViewModel(asset: asset),
            theme: ASAAboutScreenInteractableSecondaryListItemViewTheme(),
            handlers: handlers
        )
    }
    
    private func addVerificationTier() {
        verificationTierView.customize(theme.verificationTier)
        
        
        
        contextView.addArrangedSubview(verificationTierView)
        contextView.setCustomSpacing(
            theme.spacingBetweenSectionsAndVerificationTier,
            after: verificationTierView
        )
        
        verificationTierView.startObserving(event: .learnMore) {
            [unowned self] in

            self.open(AlgorandWeb.asaVerificationSupport.link)
        }

        bindVerificationTierData()
    }

    private func addVerificationTier(atIndex index: Int) {
        verificationTierView.customize(theme.verificationTier)

        if let previousView = contextView.arrangedSubviews[safe: index - 1] {
            contextView.setCustomSpacing(
                theme.spacingBetweenSectionsAndVerificationTier,
                after: previousView
            )
        }

        contextView.insertArrangedSubview(
            verificationTierView,
            preferredAt: index
        )

        if index == 0 {
            contextView.setCustomSpacing(
                theme.spacingBetweenVerificationTierAndFirstSection,
                after: verificationTierView
            )
        } else {
            contextView.setCustomSpacing(
                theme.spacingBetweenVerificationTierAndSections,
                after: verificationTierView
            )
        }

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

    private func addDescription(atIndex index: Int) {
        descriptionView.customize(theme.description)

        contextView.insertArrangedSubview(
            descriptionView,
            preferredAt: index
        )

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: descriptionView,
            margin: theme.spacingBetweenSeparatorAndDescription
        )

        bindDescriptionData()

        descriptionView.delegate = self
    }

    private func bindDescriptionData() {
        let viewModel = AssetDescriptionViewModel(asset: asset)
        descriptionView.bindData(viewModel)
    }

    private func addSocialMedia(atIndex index: Int) {
        socialMediaView.customize(theme.socialMedia)

        contextView.insertArrangedSubview(
            socialMediaView,
            preferredAt: index
        )

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: socialMediaView,
            margin: theme.spacingBetweenSeparatorAndSocialMedia
        )

        bindSocialMediaData()
    }

    private func bindSocialMediaData() {
        var items: [GroupedListItemButtonItemViewModel] = []

        /// <todo> This should properly implemented, it is a temporary solution.
        if let url = asset.discordURL {
            let item = AssetDiscordListItemViewModel {
                [unowned self] in

                self.openInBrowser(url)
            }
            items.append(item)
        }

        if let url = asset.telegramURL {
            let item = AssetTelegramListItemViewModel {
                [unowned self] in

                self.openInBrowser(url)
            }
            items.append(item)
        }

        if let url = asset.twitterURL {
            let item = AssetTwitterListItemViewModel {
                [unowned self] in

                self.openInBrowser(url)
            }
            items.append(item)
        }

        let viewModel = AssetSocialMediaGroupedListItemButtonViewModel(items: items)
        socialMediaView.bindData(viewModel)
    }

    private func addReportAction(atIndex index: Int) {
        reportActionView.customize(theme.reportAction)

        if let previousView = contextView.arrangedSubviews.last {
            contextView.setCustomSpacing(
                theme.spacingBetweenSectionsAndReportAction,
                after: previousView
            )
        }

        contextView.insertArrangedSubview(
            reportActionView,
            preferredAt: index
        )

        contextView.attachSeparator(
            theme.sectionSeparator,
            to: reportActionView,
            margin: theme.spacingBetweenSeparatorAndReportAction
        )

        reportActionView.addTouch(
            target: self,
            action: #selector(openMailComposer)
        )

        bindReportActionData()
    }

    private func bindReportActionData() {
        let viewModel = AsaReportListItemButtonViewModel(asset)
        reportActionView.bindData(viewModel)
    }
}

extension ASAMarketsFragment {
    private func openTotalSupplyInfo() {
        let uiSheet = UISheet(
            title: String(localized: "title-total-supply").bodyLargeMedium(),
            body: UISheetBodyTextProvider(text: String(localized: "asset-total-supply-body").bodyRegular())
        )

        let closeAction = UISheetAction(
            title: String(localized: "title-close"),
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

extension ASAMarketsFragment {
    @objc
    private func openMailComposer() {
        mailComposer.delegate = self
        mailComposer.configureMail(for: .report(assetId: asset.id))
        mailComposer.present(from: self)
    }
}

extension ASAMarketsFragment: ShowMoreViewDelegate {
    func showMoreViewDidTapURL(_ view: ShowMoreView, url: URL) {
        open(url)
    }
}

extension ASAMarketsFragment: MailComposerDelegate {
    func mailComposerDidSent(_ mailComposer: MailComposer) {}
    func mailComposerDidFailed(_ mailComposer: MailComposer) {}
}

extension ASAMarketsFragment {
    private enum Section {
        case profile
        case market
        case statistics
        case about
        case verificationTier
        case description
        case socialMedia
        case report

        static func ordered(by asset: Asset) -> [Section] {
            var list: [Section] = [.profile]
            
            if asset.isAvailableOnDiscover {
                list.append(.market)
            }
            
            if asset.verificationTier.isSuspicious {
                list.append(.verificationTier)
            }

            list.append(.statistics)
            list.append(.about)

            if !asset.verificationTier.isSuspicious && !asset.verificationTier.isUnverified {
                list.append(.verificationTier)
            }

            if asset.description.unwrapNonEmptyString() != nil {
                list.append(.description)
            }

            if asset.discordURL != nil ||
                asset.telegramURL != nil ||
                asset.twitterURL != nil {
                list.append(.socialMedia)
            }

            if !asset.verificationTier.isTrusted {
                list.append(.report)
            }

            return list
        }
    }
}
