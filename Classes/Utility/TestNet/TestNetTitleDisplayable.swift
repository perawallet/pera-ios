//
//  TestNetTitleDisplayable.swift

import Foundation

protocol TestNetTitleDisplayable {
    func displayTestNetTitleView(with title: String)
}

extension TestNetTitleDisplayable where Self: BaseViewController {
    func displayTestNetTitleView(with title: String) {
        guard let isTestNet = api?.isTestNet, isTestNet else {
            self.title = title
            return
        }
        
        let titleView = TestNetTitleView()
        titleView.setTitle(title)
        navigationItem.titleView = titleView
    }
}
