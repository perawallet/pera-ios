//
//  ContactInfoViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactInfoViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var contactInfoView: ContactInfoView = {
        let view = ContactInfoView()
        return view
    }()
    
    private let viewModel = ContactInfoViewModel()
    
    private let contact: Contact
    
    // MARK: Initialization
    
    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .share) {
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-info".localized
        
        viewModel.configure(contactInfoView.userInformationView, with: contact)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        contentView.addSubview(contactInfoView)
        
        contactInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
