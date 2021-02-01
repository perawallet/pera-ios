//
//  AccountListDataSource.swift

import UIKit

class AccountListDataSource: NSObject, UICollectionViewDataSource {

    private(set) var accounts = [Account]()
    private let mode: AccountListViewController.Mode
    
    init(mode: AccountListViewController.Mode) {
        self.mode = mode
        super.init()
        
        guard let userAccounts = UIApplication.shared.appConfiguration?.session.accounts else {
            return
        }
        
        switch mode {
        case .empty,
             .assetCount:
            accounts.append(contentsOf: userAccounts)
        case let .transactionReceiver(assetDetail),
             let .transactionSender(assetDetail),
             let .contact(assetDetail):
            guard let assetDetail = assetDetail else {
                accounts.append(contentsOf: userAccounts)
                return
            }
            
            let filteredAccounts = userAccounts.filter { account -> Bool in
                account.assetDetails.contains { detail -> Bool in
                     assetDetail.id == detail.id
                }
            }
            accounts = filteredAccounts
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AccountViewCell.reusableIdentifier,
            for: indexPath) as? AccountViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < accounts.count {
            let account = accounts[indexPath.item]
            cell.bind(AccountListViewModel(account: account, mode: mode))
        }
        
        return cell
    }
}
