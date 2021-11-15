// Copyright 2019 Algorand, Inc.

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
//  NotificationsView.swift

import UIKit
import Macaroon

final class NotificationsView: View {
    weak var delegate: NotificationsViewDelegate?

    private lazy var theme = NotificationsViewTheme()
    private lazy var refreshControl = UIRefreshControl()
    private lazy var noConnectionView = NoInternetConnectionView()
    private lazy var contentStateView = ContentStateView()

    private lazy var errorView: ListErrorView = {
        let errorView = ListErrorView()
        errorView.setImage(img("icon-warning-error"))
        errorView.setTitle("transaction-filter-error-title".localized)
        errorView.setSubtitle("transaction-filter-error-subtitle".localized)
        return errorView
    }()

    private lazy var notificationsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        flowLayout.sectionHeadersPinToVisibleBounds = true
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.backgroundColor = theme.backgroundColor.color
        collectionView.register(NotificationCell.self)
        return collectionView
    }()

    private lazy var emptyStateView = EmptyStateView(
        image: img("img-nc-empty"),
        title: "notifications-empty-title".localized,
        subtitle: "notifications-empty-subtitle".localized
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        linkInteractors()
    }

    func customize(_ theme: NotificationsViewTheme) {
        addNotificationsCollectionView()
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func linkInteractors() {
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        errorView.delegate = self
    }
}

extension NotificationsView {
    private func addNotificationsCollectionView() {
        addSubview(notificationsCollectionView)
        notificationsCollectionView.pinToSuperview()
        
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

    func setConnectionState() {
        notificationsCollectionView.contentState = .error(noConnectionView)
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

protocol NotificationsViewDelegate: AnyObject {
    func notificationsViewDidRefreshList(_ notificationsView: NotificationsView)
    func notificationsViewDidTryAgain(_ notificationsView: NotificationsView)
}
