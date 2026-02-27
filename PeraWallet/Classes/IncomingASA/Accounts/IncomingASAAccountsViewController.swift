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

//   IncomingASAAccountsViewController.swift

import UIKit
import Combine
import pera_wallet_core

enum InboxRowIdentifier {
    case `import`(uniqueIdentifier: String)
    case sendRequest(uniqueIdentifier: String)
    case asset(uniqueIdentifier: String)
}

protocol InboxRowIdentifiable {
    var identifier: InboxRowIdentifier? { get set }
}

final class IncomingASAAccountsViewController: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    private let model: InboxModelable
    private var viewModel: InboxViewModel { model.viewModel }

    private lazy var theme = Theme()
    
    private lazy var listDataSource: InboxDiffableDataSource = InboxDiffableDataSource(collectionView: listView, onJointAccountInviteInboxRowTap: { [weak self] in self?.model.requestAction(identifier: $0) })
    private lazy var transitionToMinimumBalanceInfo = BottomSheetTransition(presentingViewController: self)

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AccountAssetListLayout.build(backgroundColor: .clear)
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()
    
    private var positionYForVisibleAccountActionsMenuAction: CGFloat?
    private var cancellables = Set<AnyCancellable>()
        
    init(model: InboxModelable, legacyConfiguration: ViewControllerConfiguration) {
        self.model = model
        super.init(configuration: legacyConfiguration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addUI()
        view.layoutIfNeeded()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        viewModel.$rows
            .sink { [weak self] in self?.handle(rows: $0) }
            .store(in: &cancellables)
        
        viewModel.$action
            .compactMap { $0 }
            .sink { [weak self] in self?.handle(action: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: - Handlers
    
    private func handle(rows: [InboxViewModel.RowType]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, InboxViewModel.RowType>()
        snapshot.appendSections([0])
        snapshot.appendItems(rows)
        listDataSource.apply(snapshot)
    }
    
    private func handle(action: InboxViewModel.Action) {
        
        switch action {
        case let .moveToImportJointAccountScene(jointAccountAddress, subtitle, threshold, accountModels):
            presentImportJointAccountOverlay(jointAccountAddress: jointAccountAddress, subtitle: subtitle, threshold: threshold, accountModels: accountModels)
        case let .moveToRequestSendScene(request):
            if request.status == .failed || request.status == .expired || request.status == .declined {
                presentSigningStatusOverlay(request: request)
            } else {
                presentSignJointAccountTransactionScene(request: request)
            }
        case let .moveToAssetDetailsScene(address, requestCount):
            moveToAssetDetailsScene(address: address, requestCount: requestCount)
        }
    }
    
    // MARK: - Actions
    
    private func presentImportJointAccountOverlay(jointAccountAddress: String, subtitle: String, threshold: Int, accountModels: [JointAccountInviteConfirmationOverlayViewModel.AccountModel]) {
        
        let onIgnore: () -> Void = {
            Task { [weak self] in
                guard let self else { return }
                if await model.ignoreJointAccountInvitation(address: jointAccountAddress) {
                    popScreen()
                    bannerController?.presentInfoBanner(String(localized: "joint-account-invite-ignored-text"))
                }
            }
        }
        
        let onAccept: () -> Void = { [weak self] in
            self?.moveToNameAccountScene(jointAccountAddress: jointAccountAddress)
        }
        
        let controller = JointAccountInviteConfirmationOverlayConstructor.buildCompatibilityViewController(
            configuration: configuration,
            subtitle: subtitle,
            threshold: threshold,
            accountModels: accountModels,
            onIgnore: onIgnore,
            onAccept: onAccept
        )
        
        present(controller, animated: true)
    }
    
    private func presentSignJointAccountTransactionScene(request: SignRequestObject) {
        
        guard let api else { return }
        
        let transactionController = TransactionController(api: api, sharedDataController: sharedDataController, bannerController: bannerController, analytics: analytics, hdWalletStorage: hdWalletStorage)
        let controller = JointAccountTransactionRequestSummaryConstructor.buildScene(legacyConfiguration: configuration, transactionController: transactionController, request: request)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    private func presentSigningStatusOverlay(request: SignRequestObject) {
        guard let responses = request.transactionLists.first?.responses else { return }
        do {
            let signaturesInfo = try buildSignaturesInfo(
                from: request.jointAccount.participantAddresses,
                responses: responses
            )
            let signRequestMetadata = SignRequestMetadata(
                signRequestID: request.id,
                proposerAddress: request.jointAccount.address,
                signaturesInfo: signaturesInfo,
                threshold: request.jointAccount.threshold,
                deadline: request.expectedExpireDatetime
            )
            showJointAccountPendingTransactionOverlay(signRequestMetadata: signRequestMetadata)
        } catch {
            show(error: error)
        }
    }
    
    private func showJointAccountPendingTransactionOverlay(signRequestMetadata: SignRequestMetadata) {
        let viewController = JointAccountPendingTransactionOverlayConstructor.buildViewController(signRequestMetadata: signRequestMetadata)
        present(viewController, animated: true)
    }
    
    private func buildSignaturesInfo(
        from participantAddresses: [String]?,
        responses: [SignRequestTransactionResponseObject]
    ) throws -> [SignRequestInfo] {
        guard let addresses = participantAddresses else {
            throw SendTransactionPreviewScreen.InternalError.noSigner
        }
        
        return addresses.map { address in
            let status = responses.first { $0.address == address }?.response
            return SignRequestInfo(address: address, status: status)
        }
    }
    
    private func show(error: Error) {
        let title = String(localized: "title-error")
        let message = error.localizedDescription
        bannerController?.presentErrorBanner(title: title, message: message)
    }
    
    private func moveToAssetDetailsScene(address: String, requestCount: Int) {
        
        let screen = open(.inbox, by: .push) as? IncomingASAAccountsViewController
        
        screen?.eventHandler = { [weak self, weak screen] event in
            switch event {
            case .didCompleteTransaction:
                screen?.closeScreen(by: .pop, animated: false)
                self?.eventHandler?(.didCompleteTransaction)
            }
        }
    }
    
    private func moveToNameAccountScene(jointAccountAddress: String) {
        open(
            .nameAndAddJointAccount(
                jointAccountAddress: jointAccountAddress,
                onDismissRequest: { [weak self] screen in
                    guard let self else { return }
                    PeraUserDefaults.shouldShowNewAccountAnimation = true
                    screen.closeScreen(by: .pop, animated: false)
                    popScreen()
                    bannerController?.presentSuccessBanner(title: String(localized: "joint-account-invite-accepted-text"))
                }
            ),
            by: .push
        )
    }
    
    // MARK: - Deinitializer
    
    deinit {
        model.markMessagesAsRead()
    }
}

extension IncomingASAAccountsViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) {
            [unowned self] in
            let uiSheet = UISheet(
                title: String(localized: "incoming-asa-account-inbox-screen-title")
                    .bodyLargeMedium(),
                body: UISheetBodyTextProvider(text: String(localized: "incoming-asa-account-inbox-screen-info-description-title")
                    .bodyRegular())
            )

            let closeAction = UISheetAction(
                title: String(localized: "title-close"),
                style: .cancel
            ) { [unowned self] in
                self.dismiss(animated: true)
            }
            uiSheet.addAction(closeAction)

            transitionToMinimumBalanceInfo.perform(
                .sheetAction(sheet: uiSheet),
                by: .presentWithoutNavigationController
            )
        }

        rightBarButtonItems = [infoBarButton]
    }
    
    private func bindNavigationItemTitle() {
        title = String(localized: "inbox-navigation-bar-title")
    }
}

extension IncomingASAAccountsViewController {
    
    private func addUI() {
        addList()
    }

    private func addList() {
        listView.customizeAppearance(
            [
                .backgroundColor(UIColor.clear)
            ]
        )

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.delegate = self
    }
}

extension IncomingASAAccountsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? InboxRowIdentifiable, let identifier = cell.identifier else { return }
        
        switch identifier {
        case .import:
            return
        case .sendRequest, .asset:
            model.requestAction(identifier: identifier)
        }
    }
}

extension IncomingASAAccountsViewController {
    enum Event {
        case didCompleteTransaction
    }
}
