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

//   SelectAddressViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonForm
import pera_wallet_core

final class SelectAddressViewController:
    BaseScrollViewController {
    private lazy var theme = SelectAddressViewControllerTheme()
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )
    
    private lazy var currencyFormatter = CurrencyFormatter()
    
    fileprivate let dataController: SelectAddressListDataController
    fileprivate let hdWalletId: String

    private lazy var titleView = UILabel()
    private lazy var descriptionView = UILabel()
    private lazy var headerView = SelectAddressListHeaderView()
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.register(SelectAddressCell.self)
        collectionView.register(AlreadyImportedAddressCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    private lazy var actionView = Button()
    private lazy var rescanRekeyedAccountsCoordinator = RescanRekeyedAccountsCoordinator(presenter: self)

    init(
        recoveredAddresses: [RecoveredAddress],
        hdWalletId: String,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = SelectAddressListDataController(recoveredAddresses: recoveredAddresses)
        self.hdWalletId = hdWalletId
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical

        super.init(configuration: configuration)
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
}

extension SelectAddressViewController {
    private func addUI() {
        addBackground()
        addTitle()
        addDescription()
        addHeader()
        addAction()
        addAddressesList()
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
        descriptionView.text = dataController.descriptionText

        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }
    
    private func addHeader() {
        headerView.customize(theme.headerTheme)
        headerView.bindData(
            SelectAddressListHeaderViewModel(title: dataController.headerTitle)
        )
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.spacingBetweenDescriptionAndHeader
            $0.height.equalTo(theme.headerHeight)
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
        
        headerView.startObserving(event: .performAction) {
            [unowned self] in

            switch dataController.headerItemState {
            case .selectAll, .partialSelection:
                dataController.selectAllAddressItems()
            case .unselectAll:
                dataController.unselectAllAddressItems()
            }

            updateUIAfterHeaderSelection()
        }
    }
    
    private func addAddressesList() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top == headerView.snp.bottom + theme.spacingListView
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.bottom == actionView.snp.top - theme.spacingListView
        }
    }

    private func addAction() {
        actionView.customizeAppearance(theme.action)
        actionView.bindData(
            ButtonCommonViewModel(title: String(localized: "account-name-setup-finish"))
        )
        actionView.isEnabled = dataController.isFinishActionEnabled

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
            action: #selector(finishAction)
        )
    }
    
    private func updateUIAfterSelection(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
        actionView.isEnabled = dataController.isFinishActionEnabled
        updateHeaderUI()
    }
    
    private func updateUIAfterHeaderSelection() {
        collectionView.reloadData()
        actionView.isEnabled = dataController.isFinishActionEnabled
        updateHeaderUI()
    }
    
    private func updateHeaderUI() {
        if dataController.isAllAddressesSelected {
            headerView.state = .unselectAll
        } else {
            headerView.state = dataController.selectedAddresses.isEmpty ? .selectAll : .partialSelection
        }
    }
    
    @objc
    private func finishAction() {
        guard let wallet = try? hdWalletStorage.wallet(id: hdWalletId) else {
            assertionFailure("Wallet should exist")
            return
        }
        
        var accountsInfos: [AccountInformation] = []
        
        for selectedAddress in dataController.selectedAddresses {
            let hdWalletAddressDetail = HDWalletAddressDetail(
                walletId: wallet.id,
                account: selectedAddress.accountIndex,
                change: 0,
                keyIndex: selectedAddress.addressIndex
            )
            
            let accountInformation = AccountInformation(
                address: selectedAddress.address,
                name: selectedAddress.address.shortAddressDisplay,
                isWatchAccount: false,
                preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
                isBackedUp: true,
                hdWalletAddressDetail: hdWalletAddressDetail
            )
            
            accountsInfos.append(accountInformation)
            
            guard
                let hdWalletAddress = try? hdWalletService.importAddress(selectedAddress, for: wallet),
                let _ = try? hdWalletStorage.save(address: hdWalletAddress)
            else {
                assertionFailure("Couldn't create HDWalletAddress")
                return
            }
            
            if let authenticatedUser = session?.authenticatedUser {
                authenticatedUser.addAccount(accountInformation)
                pushNotificationController.sendDeviceDetails()
            } else {
                let user = User(accounts: [accountInformation])
                session?.authenticatedUser = user
            }
        }
        
        let accounts = accountsInfos.map { Account(localAccount: $0) }
        rescanRekeyedAccountsCoordinator.rescan(accounts: accounts, nextStep: .returnToHomeScreen)
    }
}

extension SelectAddressViewController: UICollectionViewDelegateFlowLayout {
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

extension SelectAddressViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.addresses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let recoveredAddress = dataController.getAddress(at: indexPath.row) else {
            fatalError("Should not be nil")
        }
        
        if recoveredAddress.alreadyImported {
            let cell = collectionView.dequeue(
                AlreadyImportedAddressCell.self,
                at: indexPath
            )
            cell.bindData(
                AlreadyImportedAddressListItemViewModel(
                    recoveredAddress
                )
            )
            return cell
        } else {
            let cell = collectionView.dequeue(
                SelectAddressCell.self,
                at: indexPath
            )
            
            cell.accessory = dataController.isAddressSelected(at: indexPath.row) ? .selected : .unselected
            cell.bindData(
                SelectAddressListItemViewModel(
                    recoveredAddress,
                    currencyFormatter: currencyFormatter,
                    currencyProvider: sharedDataController.currency
                )
            )
            return cell
        }
    }
}

extension SelectAddressViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.updateSelectionWithItem(at: indexPath.row)
        updateUIAfterSelection(at: [indexPath])
    }
}
