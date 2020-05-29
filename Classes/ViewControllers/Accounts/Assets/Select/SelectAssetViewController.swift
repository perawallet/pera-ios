//
//  SelectAssetViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SelectAssetViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SelectAssetViewControllerDelegate?
    
    private lazy var selectAssetView = SelectAssetView()
    
    private let viewModel = SelectAssetViewModel()
    
    private var accounts = [Account]()
    
    private let transactionAction: TransactionAction
    
    private let filterOption: FilterOption
    
    init(transactionAction: TransactionAction, filterOption: FilterOption, configuration: ViewControllerConfiguration) {
        self.transactionAction = transactionAction
        self.filterOption = filterOption
        super.init(configuration: configuration)
        accounts = filterAccounts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
        navigationItem.title = "send-select-asset".localized
    }
    
    override func setListeners() {
        selectAssetView.accountsCollectionView.delegate = self
        selectAssetView.accountsCollectionView.dataSource = self
    }

    override func prepareLayout() {
        setupSelectAssetViewLayout()
    }
}

extension SelectAssetViewController {
    private func setupSelectAssetViewLayout() {
        view.addSubview(selectAssetView)
        
        selectAssetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func filterAccounts() -> [Account] {
        guard let allAccounts = UIApplication.shared.appConfiguration?.session.accounts else {
            return []
        }
        
        switch filterOption {
        case .none:
            return allAccounts
        case .algos:
            allAccounts.forEach { $0.assetDetails.removeAll() }
            return allAccounts
        case let .asset(assetDetail):
            let filteredAccounts = allAccounts.filter { account -> Bool in
                account.assetDetails.contains { detail -> Bool in
                     assetDetail.id == detail.id
                }
            }
            
            filteredAccounts.forEach { account in
                account.assetDetails.removeAll { asset -> Bool in
                    assetDetail.id != asset.id
                }
            }
            
            return filteredAccounts
        }
    }
}

extension SelectAssetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let account = accounts[section]
        
        switch filterOption {
        case .none:
            if account.assetDetails.isEmpty {
                return 1
            }
            
            return account.assetDetails.count + 1
        case .algos,
             .asset:
            return 1
        }
    }
}

extension SelectAssetViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch filterOption {
        case .none:
            if indexPath.item == 0 {
                return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
            }
            return dequeueAssetCell(in: collectionView, cellForItemAt: indexPath)
        case .algos:
            return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
        case .asset:
            return dequeueAssetCell(in: collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func dequeueAlgoAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlgoAssetCell.reusableIdentifier,
            for: indexPath) as? AlgoAssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.section < accounts.count {
            let account = accounts[indexPath.section]
            viewModel.configure(cell, with: account)
        }
        
        return cell
    }
    
    private func dequeueAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetCell.reusableIdentifier,
            for: indexPath) as? AssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        let account = accounts[indexPath.section]
        let assetDetail: AssetDetail
        
        switch filterOption {
        case .none:
            assetDetail = account.assetDetails[indexPath.item - 1]
        default:
            assetDetail = account.assetDetails[indexPath.item]
        }
        
        if let assets = account.assets,
            let assetId = assetDetail.id,
            let asset = assets["\(assetId)"] {
            viewModel.configure(cell, with: assetDetail, and: asset)
        }
        
        return cell
    }
}

extension SelectAssetViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SelectAssetHeaderSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? SelectAssetHeaderSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        let account = accounts[indexPath.section]
        viewModel.configure(headerView, with: account)
        
        headerView.tag = indexPath.section
        
        return headerView
    }
}

extension SelectAssetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.itemHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.headerHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return .zero
    }
}

extension SelectAssetViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let account = accounts[safe: indexPath.section] else {
            return
        }
        
        dismissScreen()
        
        switch filterOption {
        case .none:
            if indexPath.item == 0 {
                delegate?.selectAssetViewController(self, didSelectAlgosIn: account, forAction: transactionAction)
            } else {
                if let assetDetail = account.assetDetails[safe: indexPath.item - 1] {
                    delegate?.selectAssetViewController(self, didSelect: assetDetail, in: account, forAction: transactionAction)
                }
            }
        case .algos:
            delegate?.selectAssetViewController(self, didSelectAlgosIn: account, forAction: transactionAction)
        case let .asset(asset):
            if let assetDetail = account.assetDetails.first(where: { filteredAsset -> Bool in
                asset.id == filteredAsset.id
            }) {
                delegate?.selectAssetViewController(self, didSelect: assetDetail, in: account, forAction: transactionAction)
            }
        }
    }
}

extension SelectAssetViewController {
    enum FilterOption {
        case none
        case algos
        case asset(assetDetail: AssetDetail)
    }
}

extension SelectAssetViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultSectionInsets = UIEdgeInsets.zero
        let headerHeight: CGFloat = 48.0
        let itemHeight: CGFloat = 52.0
    }
}

protocol SelectAssetViewControllerDelegate: class {
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelectAlgosIn account: Account,
        forAction transactionAction: TransactionAction
    )
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelect assetDetail: AssetDetail,
        in account: Account,
        forAction transactionAction: TransactionAction
    )
}
