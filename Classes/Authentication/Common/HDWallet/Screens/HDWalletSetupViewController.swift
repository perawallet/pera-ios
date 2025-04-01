// Copyright 2024 Pera Wallet, LDA

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
//   HDWalletSetupViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonForm

final class HDWalletSetupViewController:
    BaseScrollViewController {
    private lazy var theme = HDWalletSetupViewControllerTheme()
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private lazy var titleView = UILabel()
    private lazy var descriptionView = UILabel()
    private lazy var actionView = Button(.imageAtLeft(spacing: theme.actionSpacingBetweenIconAndTitle))

    private let flow: AccountSetupFlow
    private let mode: AccountSetupMode
    fileprivate let dataController: HDWalletSetupDataController
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.register(HDWalletCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    init(
        flow: AccountSetupFlow,
        mode: AccountSetupMode,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        self.mode = mode
        self.dataController = HDWalletSetupDataController(configuration: configuration)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical

        super.init(configuration: configuration)
        loadingController?.startLoadingWithMessage("title-loading".localized)
        setupCallbacks()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func configureAppearance() {
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        let baseGradientColor = Colors.Defaults.background.uiColor
        backgroundGradient.colors = [
            baseGradientColor.withAlphaComponent(0),
            baseGradientColor
        ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
    
    private func setupCallbacks() {
        dataController.eventHandler = { event in
            switch event {
            case .didFinishFastLookup:
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.loadingController?.stopLoading()
                }
            }
        }
    }
}

extension HDWalletSetupViewController {
    private func addUI() {
        addBackground()
        addTitle()
        addDescription()
        addAction()
        addWalletList()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addAction() {
        actionView.customizeAppearance(theme.action)
        actionView.bindData(
            ButtonCommonViewModel(
                title: "account-type-selection-create-wallet".localized,
                iconSet: [.normal("icon-plus-24")])
        )

        footerView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionView.snp.makeConstraints {
            $0.top == theme.actionContentEdgeInsets.top
            $0.leading == theme.actionContentEdgeInsets.leading
            $0.trailing == theme.actionContentEdgeInsets.trailing
            $0.bottom == theme.actionContentEdgeInsets.bottom
        }

        actionView.addTouch(
            target: self,
            action: #selector(createNewWallet)
        )
    }
    
    private func addWalletList() {

        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.spacingListView
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.bottom == actionView.snp.top - theme.spacingListView
        }
    }
}

extension HDWalletSetupViewController {
    private func select(existingHDWallet: HDWalletInfoViewModel) {
        guard let hdWallet = try? hdWalletStorage.wallet(id: existingHDWallet.walletId) else {
            assertionFailure("HDWallet should exist")
            return
        }
        
        guard
            let accountIndex = session?.authenticatedUser?.nextAccountIndex(forWalletId: hdWallet.id),
            let hdWalletAddress = try? hdWalletService.generateAddress(
                for: hdWallet,
                at: accountIndex
        ) else {
            assertionFailure("Error generating address")
            return
        }
        
        do {
            try hdWalletStorage.save(address: hdWalletAddress)
        } catch {
            assertionFailure(error.localizedDescription)
            return
        }
        
        analytics.track(.onboardCreateAccount(type: .new))
        
        let account = AccountInformation(
            address: hdWalletAddress.address,
            name: hdWalletAddress.address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: false,
            hdWalletAddressDetail: hdWalletService.createAddressDetail(for: existingHDWallet, in: accountIndex)
        )
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }

        let screen = open(
            .addressNameSetup(
                flow: flow,
                mode: .addBip39Address(newAddress: hdWalletAddress),
                account: account
            ),
            by: .push
        ) as? AddressNameSetupViewController
        screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        screen?.hidesCloseBarButtonItem = true
    }

    @objc
    private func createNewWallet() {
        open(
            .tutorial(
                flow: flow,
                tutorial: .backUpBip39(
                    flow: flow,
                    address: "temp"
                ),
                walletFlowType: .bip39
            ),
            by: .push
        )
    }
}

extension HDWalletSetupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 76
        return CGSize(width: width, height: height)
    }
}

extension HDWalletSetupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataController.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(
            HDWalletCell.self,
            at: indexPath
        )
        
        cell.bindData(dataController.items[indexPath.row])
        return cell
    }
}

extension HDWalletSetupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(existingHDWallet: dataController.itemInfo(at: indexPath.row))
    }
}
