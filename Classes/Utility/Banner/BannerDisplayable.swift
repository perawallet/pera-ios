//
//  BannerDisplayable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

protocol BannerDisplayable {
    var statusBarView: UIView { get }
    var shouldDisplayBanner: Bool { get }
    func addBanner()
    func removeBanner()
}

extension BannerDisplayable where Self: UIViewController {
    func addBanner() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        if !shouldDisplayBanner {
            removeBanner()
            return
        }

        if statusBarView.superview != nil {
            return
        }

        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        window.addSubview(statusBarView)

        statusBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(statusBarHeight)
            make.top.leading.trailing.equalToSuperview()
        }
    }

    func removeBanner() {
        if statusBarView.superview != nil {
            statusBarView.removeFromSuperview()
        }
    }
}
