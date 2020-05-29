//
//  NotificationsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class NotificationsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var notificationsComingSoonView = ComingSoonView()
    
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        notificationsComingSoonView.setTitle("notifications-title".localized)
        notificationsComingSoonView.setDetail("notifications-coming-soon-detail-text".localized)
    }
    
    override func prepareLayout() {
        view.addSubview(notificationsComingSoonView)
        
        notificationsComingSoonView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
