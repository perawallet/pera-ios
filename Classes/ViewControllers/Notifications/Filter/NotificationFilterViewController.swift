//
//  NotificationFilterViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NotificationFilterViewController: BaseViewController {

    private lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = .zero
        collectionView.register(AccountNameSwitchCell.self, forCellWithReuseIdentifier: AccountNameSwitchCell.reusableIdentifier)
        return collectionView
    }()

    override func prepareLayout() {
        setupAccountsCollectionViewLayout()
    }
}

extension NotificationFilterViewController {
    private func setupAccountsCollectionViewLayout() {
        view.addSubview(accountsCollectionView)

        accountsCollectionView.snp.makeConstraints { make in
            make.top.safeEqualToTop(of: self)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
