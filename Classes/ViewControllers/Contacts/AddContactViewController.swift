//
//  AddContactViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AddContactViewController: BaseViewController {

    // MARK: Components
    
    private lazy var addContactView: AddContactView = {
        let view = AddContactView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-add".localized
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(addContactView)
        
        addContactView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
