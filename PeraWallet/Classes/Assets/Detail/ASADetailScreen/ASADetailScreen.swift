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

//   ASADetailScreen.swift

import MacaroonUIKit
import MacaroonUtils
import SnapKit
import UIKit
import Combine
import pera_wallet_core

final class ASADetailScreen:
    BaseViewController,
    Container {
    
    // MARK: - Data Source
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<ASADetailScreenSection, ASADetailScreenItem>(
        collectionView: collectionView
    ) { [weak self] collectionView, indexPath, itemIdentifier in
        guard let self = self else { return UICollectionViewCell() }
        return self.cell(for: itemIdentifier, at: indexPath)
    }
    
    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var loadingView = makeLoading()
    private lazy var errorView = makeError()
    private lazy var profileView = ASAProfileView()
    private lazy var quickActionsView = ASADetailQuickActionsView()
    private lazy var marketInfoView = ASADetailMarketView()
    private lazy var pagesScreen = PageContainer(configuration: configuration, hidePageBar: true)
    
    private lazy var activityFragmentScreen = ASAActivityScreen(
        account: dataController.account,
        asset: dataController.asset,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )
    private lazy var aboutFragmentScreen = ASAAboutScreen(
        asset: dataController.asset,
        copyToClipboardController: copyToClipboardController,
        configuration: configuration
    )

    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = Colors.Defaults.background.uiColor
        return collectionView
    }()

    private lazy var meldFlowCoordinator = MeldFlowCoordinator(
        analytics: analytics,
        presentingScreen: self
    )
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(
            account: dataController.account,
            assetInID: dataController.asset.id
        ),
        dataStore: swapDataStore,
        configuration: configuration,
        presentingScreen: self
    )
    private lazy var sendTransactionFlowCoordinator = SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController,
        account: dataController.account,
        asset: dataController.asset
    )
    private lazy var receiveTransactionFlowCoordinator =
        ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var undoRekeyFlowCoordinator = UndoRekeyFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToStandardAccountFlowCoordinator = RekeyToStandardAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var rekeyToLedgerAccountFlowCoordinator = RekeyToLedgerAccountFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var accountInformationFlowCoordinator = AccountInformationFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )

    private lazy var rekeyingValidator = RekeyingValidator(
        session: session!,
        sharedDataController: sharedDataController
    )

    private var lastDisplayState = DisplayState.normal
    private var isViewLayoutLoaded = false
    private var selectedPageIndex = 0
    private var activityContentHeight: CGFloat = 600

    private var shouldDisplayMarketInfo: Bool {
        dataController.asset.isAvailableOnDiscover
    }

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore
    private let dataController: ASADetailScreenDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme = ASADetailScreenTheme()
    
    private var cancellables = Set<AnyCancellable>()

    init(
        swapDataStore: SwapDataStore,
        dataController: ASADetailScreenDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.swapDataStore = swapDataStore
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
        addNavigationActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupViews()
        loadData()
        setupCallbacks()
        
        updateSnapshot()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            isViewLayoutLoaded = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
        activityFragmentScreen.scrollView.isScrollEnabled = false
        aboutFragmentScreen.scrollView.isScrollEnabled = false
        
        activityFragmentScreen.onContentHeightUpdated = { [weak self] height in
            guard let self else { return }
            if height > activityContentHeight {
                activityContentHeight = height + 100 /// add 100px to leave some bottom padding and garantee the last row is not cut
                
                dataSource.apply(dataSource.snapshot())
                pagesScreen.pagesView.collectionViewLayout.invalidateLayout()
                pagesScreen.pagesView.layoutIfNeeded()
                activityFragmentScreen.onContentHeightUpdated = nil
            }
        }
        
        // Set up the page items after the view hierarchy is established
        if !isPagesScreenConfigured {
            UIView.performWithoutAnimation {
                pagesScreen.items = [
                    ActivityPageBarItem(screen: activityFragmentScreen),
                    AboutPageBarItem(screen: aboutFragmentScreen)
                ]
                isPagesScreenConfigured = true
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
        
        activityFragmentScreen.onContentHeightUpdated = nil
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        bindUIDataWhenPreferredUserInterfaceStyleDidChange()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        ObservableUserDefaults.shared.$isPrivacyModeEnabled
            .sink { [weak self] in self?.bindProfileData(isAmountHidden: $0) }
            .store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [
            ASADetailProfileCell.self,
            ASADetailQuickActionsCell.self,
            ASADetailMarketInfoCell.self,
            ASADetailPageContainerCell.self
        ].forEach {
            collectionView.register($0)
        }
        
        collectionView.register(header: ASADetailPageContainerHeader.self)
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader,
               let section = self.dataSource.snapshot().sectionIdentifiers[safe: indexPath.section],
               section == .pageContainer {
                let header = collectionView.dequeueHeader(ASADetailPageContainerHeader.self, at: indexPath)
                header.onActivityButtonPressed = { [weak self] in
                    guard let self else { return }
                    pagesScreen.selectedIndex = 0
                }
                header.onAboutButtonPressed = { [weak self] in
                    guard let self else { return }
                    pagesScreen.selectedIndex = 1
                }
                return header
            }

            return nil
        }
        
        collectionView.dataSource = dataSource
    }
    
    private func setupViews() {
        view.customizeAppearance(theme.background)
        setupProfileView()
        setupQuickActionsView()
        setupMarketInfoView()
        setupPageFragments()
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil }
            
            let sectionIdentifiers = self.dataSource.snapshot().sectionIdentifiers
            guard sectionIndex < sectionIdentifiers.count else { return nil }
            
            let section = sectionIdentifiers[sectionIndex]
            return self.createLayoutSection(for: section, environment: layoutEnvironment)
        }
        
        return layout
    }
    
    private func createLayoutSection(for section: ASADetailScreenSection, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch section {
        case .profile:
            return createProfileSection(environment: environment)
        case .quickActions:
            return createQuickActionsSection(environment: environment)
        case .marketInfo:
            return createMarketInfoSection(environment: environment)
        case .pageContainer:
            return createPageContainerSection(environment: environment)
        }
    }
    
    private func createProfileSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 24,
            bottom: 0,
            trailing: 24
        )
        
        return section
    }
    
    private func createQuickActionsSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 24,
            bottom: 0,
            trailing: 24
        )
        
        return section
    }
    
    private func createMarketInfoSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 24,
            bottom: 0,
            trailing: 24
        )
        
        return section
    }
    
    private func createPageContainerSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(activityContentHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(activityContentHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 20,
            trailing: 0
        )
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(76)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private var isPagesScreenConfigured = false

    private func setupPageFragments() {
        addChild(pagesScreen)
        pagesScreen.didMove(toParent: self)
        
        // Force view loading to establish the view hierarchy
        _ = pagesScreen.view
    }

    private func cell(for itemIdentifier: ASADetailScreenItem, at indexPath: IndexPath) -> UICollectionViewCell {
        switch itemIdentifier {
        case .profile:
            let cell = collectionView.dequeue(
                ASADetailProfileCell.self,
                at: indexPath
            )
            cell.configure(with: profileView)
            return cell
        case .quickActions:
            let cell = collectionView.dequeue(
                ASADetailQuickActionsCell.self,
                at: indexPath
            )
            cell.configure(with: quickActionsView)
            return cell
        case .marketInfo:
            let cell = collectionView.dequeue(
                ASADetailMarketInfoCell.self,
                at: indexPath
            )
            cell.configure(with: marketInfoView)
            return cell
        case .pageContainer:
            let cell = collectionView.dequeue(
                ASADetailPageContainerCell.self,
                at: indexPath
            )
            cell.configure(with: pagesScreen.view)
            return cell
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<ASADetailScreenSection, ASADetailScreenItem>()
        
        // Profile section
        snapshot.appendSections([.profile])
        snapshot.appendItems([.profile], toSection: .profile)
        
        // Quick actions section (if should display)
        if dataController.configuration.shouldDisplayQuickActions {
            snapshot.appendSections([.quickActions])
            snapshot.appendItems([.quickActions], toSection: .quickActions)
        }
        
        // Market info section (if should display)
        if shouldDisplayMarketInfo {
            snapshot.appendSections([.marketInfo])
            snapshot.appendItems([.marketInfo], toSection: .marketInfo)
        }
        
        // PageContainer section
        snapshot.appendSections([.pageContainer])
        snapshot.appendItems([.pageContainer], toSection: .pageContainer)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ASADetailScreen {
    func optionsViewControllerDidUndoRekey(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        undoRekeyFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToLedger(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        rekeyToLedgerAccountFlowCoordinator.launch(sourceAccount)
    }
    
    func optionsViewControllerDidOpenRekeyingToStandardAccount(_ optionsViewController: OptionsViewController) {
        let sourceAccount = dataController.account
        rekeyToStandardAccountFlowCoordinator.launch(sourceAccount)
    }
}

extension ASADetailScreen {
    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let account = dataController.account
        let viewModel = AccountNameTitleViewModel(account)
        navigationTitleView.bindData(viewModel)
    }

    private func addNavigationActions() {
        var rightBarButtonItems: [ALGBarButtonItem] = []

        if dataController.configuration.shouldDisplayAccountActionsBarButtonItem {
            let accountActionsBarButtonItem = makeAccountActionsBarButtonItem()
            rightBarButtonItems.append(accountActionsBarButtonItem)
        }

        if rightBarButtonItems.isEmpty {
            let flexibleSpaceItem = ALGBarButtonItem.flexibleSpace()
            rightBarButtonItems.append(flexibleSpaceItem)
        }

        self.rightBarButtonItems = rightBarButtonItems
    }

    private func makeAccountActionsBarButtonItem() ->  ALGBarButtonItem {
        let account = dataController.account
        let accountActionsItem = ALGBarButtonItem(kind: .account(account)) {
            [unowned self] in
            openAccountInformationScreen()
        }

        return accountActionsItem
    }

    private func openAccountInformationScreen() {
        let sourceAccount = dataController.account
        accountInformationFlowCoordinator.launch(sourceAccount)
    }

    private func updateUIWhenViewLayoutDidChangeIfNeeded() {
        if !isViewLayoutLoaded { return }
        // Remove updateSnapshot() call from here since it's now called in viewDidLoad
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateUIWhenAccountDidRename() {
        bindNavigationTitle()
    }

    private func updateUIWhenDataWillLoad() {
        addLoading()
        removeError()
    }

    private func updateUIWhenDataDidLoad() {
        bindUIData()
        removeLoading()
        removeError()
        updateSnapshot() // Keep this call to refresh data when loaded
    }

    private func updateUIWhenDataDidFailToLoad(_ error: ASADetailScreenDataController.Error) {
        addError()
        removeLoading()
    }

    private func updateUI(for state: DisplayState) {
        collectionView.reloadData()
    }

    private func bindUIData() {
        bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
        bindMarketData()
        bindPagesFragmentData()
    }

    private func bindUIDataWhenPreferredUserInterfaceStyleDidChange() {
        bindProfileDataWhenPreferredUserInterfaceStyleDidChange()
    }

    private func makeLoading() -> ASADetailLoadingView {
        let loadingView = ASADetailLoadingView()
        loadingView.customize(theme.loading)
        return loadingView
    }

    private func addLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        loadingView.startAnimating()
    }

    private func removeLoading() {
        loadingView.removeFromSuperview()
        loadingView.stopAnimating()
    }

    private func makeError() -> NoContentWithActionView {
        let errorView = NoContentWithActionView()
        errorView.customizeAppearance(theme.errorBackground)
        errorView.customize(theme.error)
        return errorView
    }

    private func addError() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        errorView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else { return }

            self.dataController.loadData()
        }

        errorView.bindData(ListErrorViewModel())
    }

    private func removeError() {
        errorView.removeFromSuperview()
    }

    private func setupProfileView() {
        profileView.customize(theme.profile)
        
        profileView.startObserving(event: .onAmountTap) {
            ObservableUserDefaults.shared.isPrivacyModeEnabled.toggle()
        }
        
        profileView.onPeriodChange = { [weak self] newPeriodSelected in
            guard let self else { return }
            dataController.updateChartData(address: dataController.account.address, assetId: String(dataController.asset.id), period: newPeriodSelected)
        }
        
        profileView.onPointSelected = { [weak self] pointSelected in
            guard let self else { return }

            guard
                let pointSelected,
                let date = pointSelected.timestamp.toDate(.fullNumericWithTimezone)
            else {
                bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
                return
            }
            
            bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled, chartPointSelected: ChartSelectedPointViewModel(algoValue: pointSelected.algoValue, fiatValue: pointSelected.fiatValue, usdValue: pointSelected.usdValue, dateValue: DateFormatter.chartDisplay.string(from: date)))
        }
        
        bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
    }

    private func bindProfileData(isAmountHidden: Bool, chartPointSelected: ChartSelectedPointViewModel? = nil) {
        let asset = dataController.asset
        let viewModel = ASADetailProfileViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: CurrencyFormatter(),
            isAmountHidden: isAmountHidden,
            selectedPointVM: chartPointSelected
        )
        profileView.bindData(viewModel)
    }

    private func bindProfileDataWhenPreferredUserInterfaceStyleDidChange() {
        let asset = dataController.asset

        var viewModel = ASADiscoveryProfileViewModel()
        viewModel.bindIcon(asset: asset)
        profileView.bindIcon(viewModel)
    }

    private func setupQuickActionsView() {
        if !dataController.configuration.shouldDisplayQuickActions {
            return
        }

        quickActionsView.customize(theme.quickActions)

        let asset = dataController.asset
        let viewModel = ASADetailQuickActionsViewModel(
            asset: asset,
            shouldShowStakeAction: configuration.featureFlagService.isEnabled(.webviewV2Enabled)
        )

        quickActionsView.startObserving(event: .buy) {
            [unowned self] in
            self.navigateToBuyAlgoIfPossible()
        }
        quickActionsView.startObserving(event: .swap) {
            [unowned self] in

            self.navigateToSwapAssetIfPossible()
        }
        quickActionsView.startObserving(event: .stake) {
            [unowned self] in

            self.navigateToStake()
        }
        quickActionsView.startObserving(event: .send) {
            [unowned self] in
            self.navigateToSendTransactionIfPossible()
        }
        quickActionsView.startObserving(event: .receive) {
            [unowned self] in
            self.navigateToReceiveTransaction()
        }

        quickActionsView.bindData(viewModel)
    }

    private func setupMarketInfoView() {
        marketInfoView.customize(theme.marketInfo)

        marketInfoView.startObserving(event: .market) {
            [unowned self] in
            let asset = self.dataController.asset

            let assetDetail = DiscoverAssetParameters(asset: asset)
            self.open(
                .discoverAssetDetail(assetDetail),
                by: .push
            )
        }

        bindMarketData()
    }

    private func bindMarketData() {
        let asset = dataController.asset
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

    private func bindPagesFragmentData() {
        bindAboutPageData()
    }

    private func bindAboutPageData() {
        let asset = dataController.asset
        
        // Get the about screen from the page container (second screen)
        if let aboutScreen = pagesScreen.screens.last as? ASAAboutScreen {
            aboutScreen.bindData(asset: asset)
        }
    }
}

extension ASADetailScreen {
    @objc
    private func copyAccountAddress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }
}

extension ASADetailScreen {
    private func loadData() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadData: self.updateUIWhenDataWillLoad()
            case .didLoadData: self.updateUIWhenDataDidLoad()
            case .didFailToLoadData(let error): self.updateUIWhenDataDidFailToLoad(error)
            case .didUpdateAccount(let old): self.updateNavigationItemsIfNeededWhenAccountDidUpdate(old: old)
            case .didFetchChartData(data: let chartData, error: let errorDescription, period: let period):
                guard let chartData else {
                    self.bannerController?.presentErrorBanner(
                        title: String(localized: "pass-phrase-verify-sdk-error"),
                        message: errorDescription ?? ""
                    )
                    profileView.updateChart(with: ChartViewData(period: period, chartValues: [], isLoading: false), and: TendenciesViewModel(chartData: nil, currency: configuration.sharedDataController.currency))
                    return
                }
                profileView.updateChart(with: chartData, and: TendenciesViewModel(chartData: chartData.model.data, currency: configuration.sharedDataController.currency))
            case .didFetchPriceChartData, .didUpdateAssetStatus, .didFailToToogleStatus: break
            }
        }
        dataController.loadData()
        dataController.fetchInitialChartData(address: dataController.account.address, assetId: String(dataController.asset.id), period: .oneWeek)
    }
}

extension ASADetailScreen {
    private func updateNavigationItemsIfNeededWhenAccountDidUpdate(old: Account) {
        if old.authorization == dataController.account.authorization {
            return
        }

        addNavigationActions()
        bindNavigationTitle()
        setNeedsRightBarButtonItemsUpdate()
    }
}

extension ASADetailScreen {
    private func navigateToBuyAlgoIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        meldFlowCoordinator.launch(account)
    }

    private func navigateToSwapAssetIfPossible() {
        guard let rootViewController = UIApplication.shared.rootViewController() else { return }
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        analytics.track(.tapSwapInAlgoDetail())
        rootViewController.launch(tab: .swap, with: SwapAssetFlowDraft(account: account, assetInID: dataController.asset.id))
    }
    
    private func navigateToStake() {
        guard let rootViewController = UIApplication.shared.rootViewController() else { return }
        rootViewController.launch(tab: .stake)
    }

    private func navigateToSendTransactionIfPossible() {
        let account = dataController.account
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        sendTransactionFlowCoordinator.launch()
        analytics.track(.tapSendInDetail(account: dataController.account))
    }

    private func navigateToReceiveTransaction() {
        receiveTransactionFlowCoordinator.launch(dataController.account)
        analytics.track(.tapReceiveAssetInDetail(account: dataController.account))
    }
}

extension ASADetailScreen {
    private func presentActionsNotAvailableForAccountBanner() {
        bannerController?.presentErrorBanner(
            title: String(localized: "action-not-available-for-account-type"),
            message: ""
        )
    }
}

extension ASADetailScreen {
    private enum DisplayState: CaseIterable {
        case normal
        case folded

        var isFolded: Bool {
            return self == .folded
        }

        mutating func reverse() {
            self = reversed()
        }

        func reversed() -> DisplayState {
            switch self {
            case .normal: return .folded
            case .folded: return .normal
            }
        }
    }
}

// MARK: - Collection View Cells

class ASADetailProfileCell: UICollectionViewCell {
    private var containerView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView?.removeFromSuperview()
        containerView = nil
    }
    
    func configure(with view: UIView) {
        containerView?.removeFromSuperview()
        containerView = view
        
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

class ASADetailQuickActionsCell: UICollectionViewCell {
    private var containerView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView?.removeFromSuperview()
        containerView = nil
    }
    
    func configure(with view: UIView) {
        containerView?.removeFromSuperview()
        containerView = view
        
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

class ASADetailMarketInfoCell: UICollectionViewCell {
    private var containerView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView?.removeFromSuperview()
        containerView = nil
    }
    
    func configure(with view: UIView) {
        containerView?.removeFromSuperview()
        containerView = view
        
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

class ASADetailPageContainerCell: UICollectionViewCell {
    private var containerView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView?.removeFromSuperview()
        containerView = nil
    }
    
    func configure(with view: UIView) {
        containerView?.removeFromSuperview()
        containerView = view
        
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
