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
        
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountSelectionViewControllerDelegate?
    
    private var accounts: [Account] {
        guard let user = UIApplication.shared.appConfiguration?.session.authenticatedUser else {
            return []
        }
        
        return user.accounts
    }
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.register(AccountNameCell.self, forCellWithReuseIdentifier: AccountNameCell.reusableIdentifier)
        return collectionView
    }()
    
    // MARK: Setup
    
    override func prepareLayout() {
        view.addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.row]
            
        } else {
            
        }
        
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
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.row]
            delegate?.accountSelectionViewController(self, didSelect: account)
        } else {
            delegate?.accountSelectionViewControllerDidTapAddAccount(self)
        }
    }
}
