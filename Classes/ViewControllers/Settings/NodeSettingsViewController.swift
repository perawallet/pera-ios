//
//  NodeSettingsViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NodeSettingsViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var emptyStateView = EmptyStateView(
        title: "contacts-empty-text".localized,
        topImage: img("icon-contacts-empty"),
        bottomImage: img("icon-contacts-empty")
    )
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
            
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func linkInteractors() {
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-title".localized
        
        fetchContacts()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        
    }
}
