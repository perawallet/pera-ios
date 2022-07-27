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

//
//   HomeViewController.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class HomeViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var storyTransition = AlertUITransition(presentingViewController: self)
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var navigationView = HomePortfolioNavigationView()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!,
        bannerController: bannerController
    )

    private lazy var buyAlgoFlowCoordinator = BuyAlgoFlowCoordinator(presentingScreen: self)
    private lazy var sendTransactionFlowCoordinator =
    SendTransactionFlowCoordinator(
        presentingScreen: self,
        sharedDataController: sharedDataController
    )
    private lazy var receiveTransactionFlowCoordinator =
        ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var scanQRFlowCoordinator =
        ScanQRFlowCoordinator(
            sharedDataController: sharedDataController,
            presentingScreen: self,
            api: api!,
            bannerController: bannerController!
        )

    private let copyToClipboardController: CopyToClipboardController

    private let onceWhenViewDidAppear = Once()
    private let storyOnceWhenViewDidAppear = Once()

    override var name: AnalyticsScreenName? {
        return .accounts
    }

    private lazy var listView =
        UICollectionView(frame: .zero, collectionViewLayout: HomeListLayout.build())
    private lazy var listBackgroundView = UIView()

    private lazy var listLayout = HomeListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = HomeListDataSource(listView)

    /// <todo>: Refactor
    /// This is needed for ChoosePasswordViewControllerDelegate's method.
    private var selectedAccountHandle: AccountHandle? = nil
    private var sendTransactionDraft: SendTransactionDraft?
    
    private var isViewFirstAppeared = true

    private var totalPortfolioValue: PortfolioValue?

    private let dataController: HomeDataController

    init(
        dataController: HomeDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()

        navigationView.prepareLayout(NoLayoutSheet())

        navigationItem.titleView = navigationView
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didUpdate(let updates):
                let totalPortfolioItem = updates.totalPortfolioItem

                self.totalPortfolioValue = totalPortfolioItem?.portfolioValue

                self.bindNavigation(totalPortfolioItem)

                self.configureWalletConnectIfNeeded()

                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                )

                self.presentCopyAddressStoryIfNeeded()
            }
        }
        dataController.load()

        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()

        requestAppReview()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !listView.frame.isEmpty {
            updateUIWhenViewDidLayoutSubviews()
        }
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.restartAnimating()

        if isViewFirstAppeared {
            presentPasscodeFlowIfNeeded()
            isViewFirstAppeared = false
        }
        
        dataController.fetchAnnouncements()
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil {
            switchToDefaultNavigationBarAppearance()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension HomeViewController {
    private func addBarButtons() {
        let notificationBarButtonItem = ALGBarButtonItem(kind: .notification) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(.notifications, by: .push)
        }

        rightBarButtonItems = [notificationBarButtonItem]
    }
}

extension HomeViewController {
    private func addUI() {
        addListBackground()
        addList()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenListDidScroll() {
        updateNavigationBarWhenListDidScroll()
        updateListBackgroundWhenListDidScroll()
    }

    private func updateNavigationBarWhenListDidScroll() {
        let visibleIndexPaths = listView.indexPathsForVisibleItems
        let headerVisible = visibleIndexPaths.contains(IndexPath(item: 0, section: 0))
        navigationView.animateTitleVisible(!headerVisible)
    }

    private func addListBackground() {
        listBackgroundView.customizeAppearance(
            [
                .backgroundColor(AppColors.Shared.Helpers.heroBackground)
            ]
        )

        view.addSubview(listBackgroundView)
        listBackgroundView.snp.makeConstraints {
            $0.fitToHeight(0)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func updateListBackgroundWhenListDidScroll() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateListBackgroundWhenViewDidLayoutSubviews() {
        /// <note>
        /// 250 is a number smaller than the total height of the total portfolio and the quick
        /// actions menu cells, and big enough to cover the background area when the system
        /// triggers auto-scrolling to the top because of the applying snapshot (The system just
        /// does it if the user pulls down the list extending the bounds of the content even if
        /// there isn't anything to update.)
        let preferredHeight = 250 - listView.contentOffset.y

        listBackgroundView.snp.updateConstraints {
            $0.fitToHeight(max(preferredHeight, 0))
        }
    }

    private func setListBackgroundVisible(
        _ isVisible: Bool
    ) {
        let isHidden = !isVisible

        if listBackgroundView.isHidden == isHidden {
            return
        }

        listBackgroundView.isHidden = isHidden

        if !isHidden {
            updateListBackgroundWhenViewDidLayoutSubviews()
        }
    }

    private func addList() {
        listView.customizeAppearance(
            [
                .backgroundColor(UIColor.clear)
            ]
        )

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.delegate = self
    }
}

extension HomeViewController {
    private func bindNavigation(
        _ totalPortfolioItem: TotalPortfolioItem?
    ) {
        let viewModel = HomePortfolioNavigationViewModel(totalPortfolioItem)
        navigationView.bind(viewModel)
    }
}

extension HomeViewController {
    private func linkInteractors(
        _ cell: NoContentWithActionCell
    ) {
        cell.observe(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else { return }
            
            self.open(
                .welcome(flow: .addNewAccount(mode: .none)),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
        }
    }
    
    private func linkInteractors(
        _ cell: HomePortfolioCell,
        for item: HomePortfolioViewModel
    ) {
        cell.observe(event: .showInfo) {
            [weak self] in
            guard let self = self else { return }
            
            /// <todo>
            /// How to manage it without knowing view controller. Name conventions vs. protocols???
            let eventHandler: PortfolioCalculationInfoViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .close:
                    self.dismiss(animated: true)
                }
            }

            self.modalTransition.perform(
                .portfolioCalculationInfo(
                    result: self.totalPortfolioValue,
                    eventHandler: eventHandler
                ),
                by: .presentWithoutNavigationController
            )
        }
    }

    private func linkInteractors(
        _ cell: HomeQuickActionsCell
    ) {
        cell.observe(event: .buyAlgo) {
            [weak self] in
            guard let self = self else { return }
            self.buyAlgoFlowCoordinator.launch()
        }

        cell.observe(event: .send) {
            [weak self] in
            guard let self = self else { return }
            self.sendTransactionFlowCoordinator.launch()
        }

        cell.observe(event: .receive) {
            [weak self] in
            guard let self = self else { return }
            self.receiveTransactionFlowCoordinator.launch()
        }

        cell.observe(event: .scanQR) {
            [weak self] in
            guard let self = self else { return }
            self.scanQRFlowCoordinator.launch()
        }
    }

    private func linkInteractors(
        _ cell: GenericAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.observe(event: .close) {
            [weak self] in
            guard let self = self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.observe(event: .action) {
            [weak self] in
            guard let self = self else { return }

            if let url = item.ctaUrl {
                self.openInBrowser(url)
            }
        }
    }
    
    private func linkInteractors(
        _ cell: GovernanceAnnouncementCell,
        for item: AnnouncementViewModel
    ) {
        cell.observe(event: .close) {
            [weak self] in
            guard let self = self else { return }

            self.dataController.hideAnnouncement()
        }

        cell.observe(event: .action) {
            [weak self] in
            guard let self = self else { return }

            if let url = item.ctaUrl {
                self.openInBrowser(url)
            }
        }
    }
    
    private func linkInteractors(
        _ cell: HomeAccountsHeader,
        for item: ManagementItemViewModel
    ) {
        cell.observe(event: .primaryAction) {
            let eventHandler: SortAccountListViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }

                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self = self else { return }

                    switch event {
                    case .didComplete:
                        self.dataController.reload()
                    }
                }
            }

            self.open(
                .sortAccountList(
                    dataController: SortAccountListLocalDataController(
                        session: self.session!,
                        sharedDataController: self.sharedDataController
                    ),
                     eventHandler: eventHandler
                ),
                by: .present
            )
        }
        cell.observe(event: .secondaryAction) {
            self.open(
                .welcome(flow: .addNewAccount(mode: .none)),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
        }
    }
}

extension HomeViewController {
    private func requestAppReview() {
        asyncMain(afterDuration: 1.0) {
            AlgorandAppStoreReviewer().requestReviewIfAppropriate()
        }
    }

    private func presentPasscodeFlowIfNeeded() {
        guard let session = session,
              !session.hasPassword() else {
                  return
              }

        var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()

        if !passcodeSettingDisplayStore.hasPermissionToAskAgain {
            return
        }

        passcodeSettingDisplayStore.increaseAppOpenCount()

        if passcodeSettingDisplayStore.shouldAskForPasscode {
            let controller = open(
                .tutorial(flow: .none, tutorial: .passcode),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? TutorialViewController
            controller?.uiHandlers.didTapSecondaryActionButton = { tutorialViewController in
                tutorialViewController.dismissScreen()
            }
            controller?.uiHandlers.didTapDontAskAgain = { tutorialViewController in
                tutorialViewController.dismissScreen()
                passcodeSettingDisplayStore.disableAskingPasscode()
            }
        }
    }
}

extension HomeViewController {
    private func presentCopyAddressStoryIfNeeded() {
        /// note: If any screen presented on top of home screen, it will prevent opening story screen here
        guard sharedDataController.isAvailable, presentedViewController == nil else {
            return
        }
        
        storyOnceWhenViewDidAppear.execute { [weak self] in
            guard let self = self else {
                return
            }

            self.presentCopyAddressStory()
        }
    }
    
    private func presentCopyAddressStory() {
        guard let session = session,
              session.hasAuthentication() else {
            return
        }

        var copyAddressDisplayStore = CopyAddressDisplayStore()

        if !copyAddressDisplayStore.shouldAskForCopyAddress(sharedDataController.accountCollection.count) {
            return
        }

        copyAddressDisplayStore.increaseAppOpenCount()

        let eventHandler: CopyAddressStoryScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .close:
                self.dismiss(animated: true)
            }
        }

        self.storyTransition.perform(
            .copyAddressStory(
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension HomeViewController {
    private func configureWalletConnectIfNeeded() {
        onceWhenViewDidAppear.execute { [weak self] in
            guard let self = self else {
                return
            }

            self.completeWalletConnectConfiguration()
        }
    }

    private func completeWalletConnectConfiguration() {
        reconnectToOldWCSessions()
        registerWCRequests()
    }

    private func reconnectToOldWCSessions() {
        walletConnector.reconnectToSavedSessionsIfPossible()
    }

    private func registerWCRequests() {
        let wcRequestHandler = TransactionSignRequestHandler()
        if let rootViewController = UIApplication.shared.rootViewController() {
            wcRequestHandler.delegate = rootViewController
        }
        walletConnector.register(for: wcRequestHandler)
    }
}

extension HomeViewController {
    private func presentOptions(for accountHandle: AccountHandle) {
        modalTransition.perform(
            .invalidAccount(
                account: accountHandle,
                uiInteractionsHandler: linkInvalidAccountOptionsUIInteractions(
                    accountHandle
                )
            )
            ,
            by: .presentWithoutNavigationController
        )
    }
}

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                setListBackgroundVisible(true)

                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.startAnimating()
            case .noContent:
                setListBackgroundVisible(false)
                linkInteractors(cell as! NoContentWithActionCell)
            }
        case .portfolio(let item):
            setListBackgroundVisible(true)

            switch item {
            case .portfolio(let portfolioItem):
                linkInteractors(
                    cell as! HomePortfolioCell,
                    for: portfolioItem
                )
            case .quickActions:
                linkInteractors(cell as! HomeQuickActionsCell)
            }
        case .announcement(let item):
            if item.isGeneric {
                linkInteractors(cell as! GenericAnnouncementCell, for: item)
            } else {
                linkInteractors(cell as! GovernanceAnnouncementCell, for: item)
            }
        case .account(let item):
            switch item {
            case .header(let headerItem):
                linkInteractors(
                    cell as! HomeAccountsHeader,
                    for: headerItem
                )
            default:
                break
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let account = getAccount(at: indexPath) else {
            return
        }

        selectedAccountHandle = account

        if !account.isAvailable {
            presentOptions(for: account)
            return
        }

        let eventHandler: AccountDetailViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didEdit:
                self.popScreen()
                self.dataController.reload()
            case .didRemove:
                self.popScreen()
                self.dataController.reload()
            }
        }

        open(
            .accountDetail(accountHandle: account, eventHandler: eventHandler),
            by: .push
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let account = getAccount(at: indexPath)?.value else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath
        ) { _ in
            let copyActionItem = UIAction(item: .copyAddress) {
                [unowned self] _ in
                self.copyToClipboardController.copyAddress(account)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: AppColors.Shared.System.background.uiColor
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: AppColors.Shared.System.background.uiColor
        )
    }
}

extension HomeViewController {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        updateUIWhenListDidScroll()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateUIWhenListDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView
    ) {
        updateUIWhenListDidScroll()
    }
}

extension HomeViewController: ChoosePasswordViewControllerDelegate {
    func linkInvalidAccountOptionsUIInteractions(_ accountHandle: AccountHandle) -> InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions {
        var uiInteractions = InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions()

        uiInteractions.didTapShowQRCode = {
            [weak self] in

            guard let self = self else {
                return
            }

            let draft = QRCreationDraft(
                address: accountHandle.value.address,
                mode: .address,
                title: accountHandle.value.name
            )
            self.open(
                .qrGenerator(
                    title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay,
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
        }

        uiInteractions.didTapViewPassphrase = {
            [weak self] in

            guard let self = self else {
                return
            }

            guard let session = self.session else {
                return
            }

            if !session.hasPassword() {
                self.presentPassphraseView(accountHandle)
                return
            }

            let localAuthenticator = LocalAuthenticator()

            if localAuthenticator.localAuthenticationStatus != .allowed {
                let controller = self.open(
                    .choosePassword(
                        mode: .confirm(flow: .viewPassphrase),
                        flow: nil
                    ),
                    by: .present
                ) as? ChoosePasswordViewController
                controller?.delegate = self
                return
            }

            localAuthenticator.authenticate {
                [weak self] error in

                guard let self = self,
                      error == nil else {
                          return
                      }

                self.presentPassphraseView(accountHandle)
            }
        }

        uiInteractions.didTapCopyAddress = {
            [weak self] in

            guard let self = self else {
                return
            }

            self.log(ReceiveCopyEvent(address: accountHandle.value.address))
            self.copyToClipboardController.copyAddress(accountHandle.value)
        }

        return uiInteractions
    }

    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.dismissScreen()
        
        guard let selectedAccountHandle = selectedAccountHandle else {
            return
        }

        if isConfirmed {
            presentPassphraseView(selectedAccountHandle)
        }
    }

    private func presentPassphraseView(_ accountHandle: AccountHandle) {
        modalTransition.perform(
            .passphraseDisplay(address: accountHandle.value.address),
            by: .present
        )
    }
}

extension HomeViewController {
    private func getAccount(
        at indexPath: IndexPath
    ) -> AccountHandle? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        guard case HomeItemIdentifier.account(HomeAccountItemIdentifier.cell(let item)) = itemIdentifier else {
            return nil
        }

        return dataController[item.address]
    }
}

struct PasscodeSettingDisplayStore: Storable {
    typealias Object = Any

    let appOpenCountToAskPasscode = 5

    private let appOpenCountKey = "com.algorand.algorand.passcode.app.count.key"
    private let dontAskAgainKey = "com.algorand.algorand.passcode.dont.ask.again"

    var appOpenCount: Int {
        return userDefaults.integer(forKey: appOpenCountKey)
    }

    mutating func increaseAppOpenCount() {
        userDefaults.set(appOpenCount + 1, forKey: appOpenCountKey)
    }

    var hasPermissionToAskAgain: Bool {
        return !userDefaults.bool(forKey: dontAskAgainKey)
    }

    mutating func disableAskingPasscode() {
        userDefaults.set(true, forKey: dontAskAgainKey)
    }

    var shouldAskForPasscode: Bool {
        return appOpenCount % appOpenCountToAskPasscode == 0
    }
}

struct CopyAddressDisplayStore: Storable {
    typealias Object = Any

    let accountLimit = 1
    let appOpenCountCopyAddress = 2

    private let appOpenCountKey = "com.algorand.algorand.copy.address.count.key"
    private let dontAskAgainKey = "com.algorand.algorand.copy.address.dont.ask.again"

    var appOpenCount: Int {
        return userDefaults.integer(forKey: appOpenCountKey)
    }

    mutating func increaseAppOpenCount() {
        userDefaults.set(appOpenCount + 1, forKey: appOpenCountKey)
    }
    
    func shouldAskForCopyAddress(_ addressCount: Int) -> Bool {
        return addressCount >= accountLimit && appOpenCount < appOpenCountCopyAddress
    }
}
