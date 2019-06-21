//
//  LoadingIndicator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class LoadingIndicator: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let width: CGFloat = 20.0
        let height: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupActivityIndicatorLayout()
    }
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    private func setupActivityIndicatorLayout() {
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.width.equalTo(layout.current.width)
            make.height.equalTo(layout.current.height)
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: API
    
    func show() {
        activityIndicator.startAnimating()
    }
    
    func dismiss() {
        activityIndicator.stopAnimating()
    }
}
