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
import MacaroonUtils
import MacaroonUIKit

final class HomeViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {

    private lazy var storyTransition = StoryTransition(presentingViewController: self)
    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var navigationView = HomePortfolioNavigationView()
    private lazy var listViewWhiteBackgroundView = UIView(frame: .zero)
      
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!,
        bannerController: bannerController
    )

    private lazy var buyAlgoFlowCoordinator = BuyAlgoFlowCoordinator(presentingScreen: self)
    private lazy var sendTransactionFlowCoordinator =
        SendTransactionFlowCoordinator(presentingScreen: self)
    private lazy var receiveTransactionFlowCoordinator =
        ReceiveTransactionFlowCoordinator(presentingScreen: self)
    private lazy var scanQRFlowCoordinator =
        ScanQRFlowCoordinator(sharedDataController: sharedDataController, presentingScreen: self)

    private let onceWhenViewDidAppear = Once()
    private let storyOnceWhenViewDidAppear = Once()

    override var name: AnalyticsScreenName? {
        return .accounts
    }

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = HomeListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = HomeListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = HomeListDataSource(listView)

    /// <todo>: Refactor
    /// This is needed for ChoosePasswordViewControllerDelegate's method.
    private var selectedAccountHandle: AccountHandle? = nil
    private var sendTransactionDraft: SendTransactionDraft?
    
    private var isViewFirstAppeared = true

    private let dataController: HomeDataController

    init(
        dataController: HomeDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()

        navigationView.prepareLayout(NoLayoutSheet())

        navigationItem.titleView = navigationView
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = AppColors.Shared.Layer.grayLightest.uiColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didUpdate(let snapshot):
                self.configureWalletConnectIfNeeded()
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
                self.bindNavigation()
                self.applyWhiteBackground(snapshot: snapshot)
                self.presentCopyAddressStoryIfNeeded()
            }
        }
        dataController.load()

        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()

        requestAppReview()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.restartAnimating()

        if isViewFirstAppeared {
            presentPeraIntroductionIfNeeded()
            presentPasscodeFlowIfNeeded()
            isViewFirstAppeared = false
        }
        
        dataController.fetchAnnouncements()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.stopAnimating()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = self
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleIndexPaths = listView.indexPathsForVisibleItems

        let headerVisible = visibleIndexPaths.contains(IndexPath(item: 0, section: 0))

        navigationView.startAnimationToToggleTitleVisibility(visible: !headerVisible)
    }
}

extension HomeViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addBarButtons() {
        let notificationBarButtonItem = ALGBarButtonItem(kind: .notification) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(.notifications, by: .push)
        }

        rightBarButtonItems = [notificationBarButtonItem]
    }

    private func bindNavigation() {
        guard let title = dataController.portfolioViewModel?.value?.string else {
            return
        }

        let subtitle = dataController.portfolioViewModel?.secondaryValue?.string

        navigationView.bind(title: title, subtitle: subtitle)
    }

    private func applyWhiteBackground(snapshot: HomeDataController.Snapshot) {
        guard sharedDataController.isPollingAvailable else {
            return
        }

        let sectionIndex = snapshot.indexOfSection(.announcement) ?? snapshot.indexOfSection(.quickActions)
        let loadingTheme = HomeLoadingViewTheme()

        if let index = sectionIndex, let quickActionsAttribute = listView.collectionViewLayout.layoutAttributesForItem(
            at: IndexPath(item: 0, section: index)
        ) {
            var originY = quickActionsAttribute.frame.maxY

            if sectionIndex == snapshot.indexOfSection(.quickActions) {
                originY += loadingTheme.quickActionsBottomInset()
            }

            listViewWhiteBackgroundView.frame = CGRect(x: 0, y: originY, width: listView.frame.width, height: listView.contentSize.height + UIScreen.main.bounds.height)
        } else {
            let actionSize = QuickActionsView.calculatePreferredSize(
                for: QuickActionsViewTheme(),
                fittingIn: CGSize(width: UIScreen.main.bounds.width - 48,
                                  height: .greatestFiniteMagnitude)
            )
            let height = loadingTheme.accountLabelTopInset() + actionSize.height
            listViewWhiteBackgroundView.frame = CGRect(x: 0, y: height, width: listView.frame.width, height: listView.contentSize.height + UIScreen.main.bounds.height)
        }

        if !listView.subviews.contains(listViewWhiteBackgroundView) {
            listViewWhiteBackgroundView.backgroundColor = AppColors.Shared.System.background.uiColor
            listView.addSubview(listViewWhiteBackgroundView)
            listViewWhiteBackgroundView.layer.zPosition = -999
            listViewWhiteBackgroundView.isUserInteractionEnabled = false
        }
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
                    result: item.totalValueResult,
                    eventHandler: eventHandler
                ),
                by: .presentWithoutNavigationController
            )
        }
    }

    private func linkInteractors(
        _ cell: QuickActionsCell
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
                self.open(url)
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
                self.open(url)
            }
        }
    }
    
    private func linkInteractors(
        _ cell: ManagementItemCell,
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
                    case .didReorder: self.dataController.reload()
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

    private func presentPeraIntroductionIfNeeded() {
        var peraAppLaunchStore = PeraAppLaunchStore()
        
        let appLaunchStore = ALGAppLaunchStore()

        if appLaunchStore.isOnboarding {
            peraAppLaunchStore.isOnboarded = true
            return
        }

        if peraAppLaunchStore.isOnboarded {
            return
        }
        
        peraAppLaunchStore.isOnboarded = true

        open(.peraIntroduction, by: .present)
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
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.startAnimating()
            case .noContent:
                linkInteractors(cell as! NoContentWithActionCell)
            }
        case .portfolio(let item):
            linkInteractors(
                cell as! HomePortfolioCell,
                for: item
            )
        case .account(let item):
            switch item {
            case .header(let headerItem):
                linkInteractors(
                    cell as! ManagementItemCell,
                    for: headerItem
                )
            default:
                break
            }
        case .quickActions:
            linkInteractors(cell as! QuickActionsCell)
        case .announcement(let item):
            if item.isGeneric {
                linkInteractors(cell as! GenericAnnouncementCell, for: item)
            } else {
                linkInteractors(cell as! GovernanceAnnouncementCell, for: item)
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
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let item):
            switch item {
            case .cell(let cellItem):
                guard let account = dataController[cellItem.address] else {
                    return
                }

                self.selectedAccountHandle = account
                
                if account.isAvailable {
                    let eventHandler: AccountDetailViewController.EventHandler = {
                        [weak self] event in
                        guard let self = self else { return }
                        
                        switch event {
                        case .didRemove:
                            self.popScreen()
                            self.dataController.reload()
                        }
                    }
                    open(
                        .accountDetail(accountHandle: account, eventHandler: eventHandler),
                        by: .push
                    )
                } else {
                    presentOptions(for: account)
                }
            default:
                break
            }
        default: break
        }
    }
}

extension HomeViewController: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        /// <todo> Why we don't have account.isAvailable check like in didSelect method
        guard transactionAction == .send, let draft = sendTransactionDraft else {

            switch transactionAction {
            case .send:
                selectAccountViewController.open(
                    .assetSelection(
                        filter: nil,
                        account: account
                    ),
                    by: .push
                )
            case .receive:
                selectAccountViewController.closeScreen(by: .dismiss) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    let draft = QRCreationDraft(address: account.address, mode: .address, title: account.name)
                    self.open(
                        .qrGenerator(
                            title: account.name ?? account.address.shortAddressDisplay,
                            draft: draft, isTrackable: true),
                        by: .present
                    )
                }
            case .buyAlgo:
                return
            }
            return
        }

        var transactionDraft = SendTransactionDraft(
            from: account,
            toAccount: draft.from,
            amount: draft.amount,
            transactionMode: draft.transactionMode
        )
        transactionDraft.note = draft.note
        transactionDraft.lockedNote = draft.lockedNote

        selectAccountViewController.open(.sendTransaction(draft: transactionDraft), by: .push)
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
            UIPasteboard.general.string = accountHandle.value.address
            self.bannerController?.presentInfoBanner("qr-creation-copied".localized)
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
