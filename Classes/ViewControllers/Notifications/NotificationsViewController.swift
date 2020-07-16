//
//  NotificationsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

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
    
    override func linkInteractors() {
        notificationsView.delegate = self
        notificationsView.setDataSource(dataSource)
        notificationsView.setDelegate(self)
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

extension NotificationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let notification = dataSource.notification(at: indexPath.item) else {
            return .zero
        }
        return NotificationCell.calculatePreferredSize(NotificationsViewModel(notification: notification))
    }
}

extension NotificationsViewController: NotificationsViewDelegate {
    func notificationsViewDidRefreshList(_ notificationsView: NotificationsView) {
        
    }
}
