//
//  NotificationsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import Magpie

class NotificationsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var notificationsView = NotificationsView()
    
    private lazy var dataSource: NotificationsDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return NotificationsDataSource(api: api)
    }()
    
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        getNotifications()
    }
    
    override func linkInteractors() {
        notificationsView.delegate = self
        notificationsView.setDataSource(dataSource)
        notificationsView.setDelegate(self)
        dataSource.delegate = self
    }
    
    override func prepareLayout() {
        setupNotificationsViewLayout()
    }
}

extension NotificationsViewController {
    private func setupNotificationsViewLayout() {
        view.addSubview(notificationsView)
        
        notificationsView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.safeEqualToTop(of: self)
        }
    }
}

extension NotificationsViewController {
    private func getContacts() {
        dataSource.fetchContacts()
    }
    
    private func getNotifications() {
        notificationsView.setLoadingState()
        dataSource.loadData()
    }
}

extension NotificationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let notification = dataSource.notification(at: indexPath.item),
            let notificationDetail = notification.detail else {
            return
        }
        
        openAssetDetail(from: notificationDetail)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = dataSource.viewModel(at: indexPath.item) else {
            return .zero
        }
        return NotificationCell.calculatePreferredSize(viewModel)
    }
    
    private func openAssetDetail(from notificationDetail: NotificationDetail) {
        guard let userAccounts = session?.accounts,
            let account = userAccounts.first(where: { account -> Bool in
                account.address == notificationDetail.senderAddress || account.address == notificationDetail.receiverAddress
            })  else {
            return
        }
        
        var assetDetail: AssetDetail?
        if let assetId = notificationDetail.asset?.id {
            assetDetail = account.assetDetails.first { $0.id == assetId }
        }
        
        open(.assetDetail(account: account, assetDetail: assetDetail), by: .push)
    }
}

extension NotificationsViewController: NotificationsDataSourceDelegate {
    func notificationsDataSource(_ notificationsDataSource: NotificationsDataSource, didFetch notifications: [NotificationMessage]) {
        notificationsView.endRefreshing()
        
        if notifications.isEmpty {
            notificationsView.setEmptyState()
        } else {
            notificationsView.setNormalState()
        }
        
        notificationsView.reloadData()
    }
    
    func notificationsDataSource(_ notificationsDataSource: NotificationsDataSource, didFailWith error: Error) {
        notificationsView.endRefreshing()
        notificationsView.setEmptyState()
        notificationsView.reloadData()
    }
}

extension NotificationsViewController: NotificationsViewDelegate {
    func notificationsViewDidRefreshList(_ notificationsView: NotificationsView) {
        getNotifications()
    }
}
