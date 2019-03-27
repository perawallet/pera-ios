//
//  ContactsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController {
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-title".localized
    }
}
