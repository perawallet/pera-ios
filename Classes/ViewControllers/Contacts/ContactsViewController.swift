//
//  ContactsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var contactsView: ContactsView = {
        let view = ContactsView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "contacts-empty-text".localized,
        topImage: img("icon-contacts-empty"),
        bottomImage: img("icon-contacts-empty")
    )
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
            self.open(.addContact, by: .push)
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-title".localized
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(contactsView)
        
        contactsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
