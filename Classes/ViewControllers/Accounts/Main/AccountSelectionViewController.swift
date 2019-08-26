//
//  AccountSelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountSelectionViewControllerDelegate: class {
    func accountSelectionViewController(_ accountSelectionViewController: AccountSelectionViewController, didSelect account: Account)
    func accountSelectionViewControllerDidTapAddAccount(_ accountSelectionViewController: AccountSelectionViewController)
}

class AccountSelectionViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let collectionViewInset: CGFloat = 15.0
        let accountSelectionHeight: CGFloat = 73.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountSelectionViewControllerDelegate?
    
    private var accounts: [Account] {
        guard let user = UIApplication.shared.appConfiguration?.session.authenticatedUser else {
            return []
        }
        
        return user.accounts
    }
    
    var selectedAccount: Account?
    
    private let viewModel = AccountSelectionViewModel()
    
    // MARK: Components
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 30.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: -30.0, bottom: 0.0, right: 0.0)
        collectionView.register(AccountNameCell.self, forCellWithReuseIdentifier: AccountNameCell.reusableIdentifier)
        return collectionView
    }()
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        selectedAccount = session?.authenticatedUser?.defaultAccount()
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        accountsCollectionView.delegate = self
        accountsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        view.addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.collectionViewInset)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(layout.current.accountSelectionHeight)
        }
    }
}

// MARK: API

extension AccountSelectionViewController {
    func configure(selected account: Account) {
        viewModel.configure(selected: account, among: accounts, in: accountsCollectionView)
    }
}

// MARK: UICollectionViewDataSource

extension AccountSelectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AccountNameCell.reusableIdentifier,
            for: indexPath) as? AccountNameCell else {
                fatalError("Index path is out of bounds")
        }
        
        viewModel.configure(cell, for: accounts, at: indexPath, with: selectedAccount)
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AccountSelectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return viewModel.size(for: accounts, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.row]
            selectedAccount = account
            delegate?.accountSelectionViewController(self, didSelect: account)
            
            collectionView.reloadData()
        } else {
            delegate?.accountSelectionViewControllerDidTapAddAccount(self)
        }
    }
}
