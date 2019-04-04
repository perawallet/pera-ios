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
    
    private lazy var emptyStateView = EmptyStateView(
        title: "tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-green"),
        bottomImage: img("icon-transaction-empty-blue")
    )
    
    private let viewModel = ContactInfoViewModel()
    
    private let contact: Contact
    
    // MARK: Initialization
    
    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .share) {
            // TODO: Share action
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-info".localized
        
        viewModel.configure(contactInfoView.userInformationView, with: contact)
    }
    
    override func linkInteractors() {
        contactInfoView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(contactInfoView)
        
        contactInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ContactInfoViewController: ContactInfoViewDelegate {
    
    func contactInfoViewDidTapQRCodeButton(_ contactInfoView: ContactInfoView) {
        tabBarController?.open(.contactQRDisplay(contact: contact), by: .presentWithoutNavigationController)
    }
}
