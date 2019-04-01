//
//  ContactQRDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactQRDisplayViewController: BaseViewController {

    // MARK: Components
    
    private lazy var contactQRDisplayView: ContactQRDisplayView = {
        let view = ContactQRDisplayView()
        return view
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(contactQRDisplayView)
        
        contactQRDisplayView.snp.makeConstraints { make in
            
        }
    }
}
