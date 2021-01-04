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
    
    private var isInitialFetchCompleted = false
    
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
        getNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInitialFetchCompleted {
            reloadNotifications()
        }
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveNotification(notification:)),
            name: .NotificationDidReceived,
            object: nil
        )
    }
    
    override func linkInteractors() {
        notificationsView.delegate = self
        notificationsView.setDataSource(dataSource)
        notificationsView.setListDelegate(self)
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
    @objc
    private func didReceiveNotification(notification: Notification) {
        if isInitialFetchCompleted && isViewAppeared {
            reloadNotifications()
        }
    }
}

extension NotificationsViewController {
    private func getContacts() {
        dataSource.fetchContacts()
    }
    
    private func getNotifications() {
        getContacts()
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if dataSource.shouldSendPaginatedRequest(at: indexPath.item) {
            dataSource.loadData(withRefresh: false, isPaginated: true)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return NotificationCell.calculatePreferredSize(dataSource.viewModel(at: indexPath.item))
    }
    
    private func openAssetDetail(from notificationDetail: NotificationDetail) {
        let accountDetails = dataSource.getUserAccount(from: notificationDetail)
        if let account = accountDetails.account {
            open(.assetDetail(account: account, assetDetail: accountDetails.assetDetail), by: .push)
        }
    }
}

extension NotificationsViewController: NotificationsDataSourceDelegate {
    func notificationsDataSourceDidFetchNotifications(_ notificationsDataSource: NotificationsDataSource) {
        isInitialFetchCompleted = true
        notificationsView.endRefreshing()
        
        if notificationsDataSource.isEmpty {
            notificationsView.setEmptyState()
        } else {
            notificationsView.setNormalState()
        }
        
        notificationsView.reloadData()
    }
    
    func notificationsDataSourceDidFailToFetch(_ notificationsDataSource: NotificationsDataSource) {
        isInitialFetchCompleted = true
        notificationsView.endRefreshing()
        notificationsView.setErrorState()
        notificationsView.reloadData()
    }
}

extension NotificationsViewController: NotificationsViewDelegate {
    func notificationsViewDidRefreshList(_ notificationsView: NotificationsView) {
        reloadNotifications()
    }
    
    func notificationsViewDidTryAgain(_ notificationsView: NotificationsView) {
        reloadNotifications()
    }
    
    private func reloadNotifications() {
        dataSource.clear()
        notificationsView.reloadData()
        getNotifications()
    }

    func notificationsViewDidOpenNotificationFilters(_ notificationsView: NotificationsView) {
        openNotificationFilters()
    }

    private func openNotificationFilters() {
        open(
            .notificationFilter(flow: .notifications),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }
}
