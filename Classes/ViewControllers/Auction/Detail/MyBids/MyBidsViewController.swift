//
//  MyBidsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MyBidsViewController: BaseViewController {
    
    // MARK: Components
    
    private(set) lazy var myBidsView: MyBidsView = {
        let view = MyBidsView()
        return view
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupMyBidsViewLayout()
    }
    
    private func setupMyBidsViewLayout() {
        view.addSubview(myBidsView)
        
        myBidsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
