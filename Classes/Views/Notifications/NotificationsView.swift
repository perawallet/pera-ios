//
//  NotificationsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NotificationsView: BaseView {
    
    weak var delegate: NotificationsViewDelegate?
    
    private lazy var notificationsHeaderView: MainHeaderView = {
        let view = MainHeaderView()
        view.setTitle("notifications-title".localized)
        view.setQRButtonHidden(true)
        view.setAddButtonHidden(true)
        view.setTestNetLabelHidden(true)
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        image: img("img-nc-empty"),
        title: "notifications-empty-title".localized,
        subtitle: "notifications-empty-subtitle".localized
    )
    
    private lazy var errorView = ListErrorView()
    
    private lazy var notificationsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.backgroundColor = SharedColors.secondaryBackground
        collectionView.register(NotificationCell.self, forCellWithReuseIdentifier: NotificationCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    override func configureAppearance() {
        super.configureAppearance()
        errorView.setImage(img("icon-warning-error"))
        errorView.setTitle("transaction-filter-error-title".localized)
        errorView.setSubtitle("transaction-filter-error-subtitle".localized)
    }
    
    override func linkInteractors() {
        errorView.delegate = self
    }
    
    override func prepareLayout() {
        setupNotificationsHeaderViewLayout()
        setupNotificationsCollectionViewLayout()
    }
}

extension NotificationsView {
    private func setupNotificationsHeaderViewLayout() {
        addSubview(notificationsHeaderView)
        
        notificationsHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    private func setupNotificationsCollectionViewLayout() {
        addSubview(notificationsCollectionView)
        
        notificationsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(notificationsHeaderView.snp.bottom)
        }
        
        notificationsCollectionView.backgroundView = contentStateView
        notificationsCollectionView.refreshControl = refreshControl
    }
}

extension NotificationsView {
    @objc
    private func didRefreshList() {
        delegate?.notificationsViewDidRefreshList(self)
    }
}

extension NotificationsView {
    func reloadData() {
        notificationsCollectionView.reloadData()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        notificationsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        notificationsCollectionView.dataSource = dataSource
    }
    
    var isListRefreshing: Bool {
        return refreshControl.isRefreshing
    }
    
    func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setEmptyState() {
        notificationsCollectionView.contentState = .empty(emptyStateView)
    }
    
    func setErrorState() {
        notificationsCollectionView.contentState = .error(errorView)
    }
    
    func setNormalState() {
        notificationsCollectionView.contentState = .none
    }
    
    func setLoadingState() {
        if !refreshControl.isRefreshing {
            notificationsCollectionView.contentState = .loading
        }
    }
}

extension NotificationsView: ListErrorViewDelegate {
    func listErrorViewDidTryAgain(_ listErrorView: ListErrorView) {
        delegate?.notificationsViewDidTryAgain(self)
    }
}

protocol NotificationsViewDelegate: class {
    func notificationsViewDidRefreshList(_ notificationsView: NotificationsView)
    func notificationsViewDidTryAgain(_ notificationsView: NotificationsView)
}
