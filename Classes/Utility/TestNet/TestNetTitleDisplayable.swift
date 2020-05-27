//
//  TestNetTitleDisplayable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

protocol TestNetTitleDisplayable {
    func displayTestNetTitleView(with title: String)
}

extension TestNetTitleDisplayable where Self: BaseViewController {
    func displayTestNetTitleView(with title: String) {
        guard let isTestNet = api?.isTestNet else {
            self.title = title
            return
        }
        
        if isTestNet {
            let titleView = TestNetTitleView()
            titleView.setTitle(title)
            navigationItem.titleView = titleView
        } else {
            self.title = title
        }
    }
}
