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

    private lazy var notificationsComingSoonView = NotificationsComingSoonView()
    
    override func prepareLayout() {
        view.addSubview(notificationsComingSoonView)
        
        notificationsComingSoonView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
