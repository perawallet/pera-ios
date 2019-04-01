//
//  ContactInfoViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactInfoViewController: BaseViewController {

    // MARK: Components
    
    private lazy var contactInfoView: ContactInfoView = {
        let view = ContactInfoView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .share) {
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-info".localized
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(contactInfoView)
        
        contactInfoView.snp.makeConstraints { make in
            
        }
    }
}
