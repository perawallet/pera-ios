//
//  BaseScrollViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class BaseScrollViewController: BaseViewController {
    
    // MARK: Components
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private(set) lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    // MARK: Variables
    
    var shouldIgnoreTopLayoutGuide = true {
        didSet {
            
            if shouldIgnoreTopLayoutGuide == oldValue {
                return
            }
            
            updateScrollViewLayout()
        }
    }
    
    var shouldIgnoreBottomLayoutGuide = true {
        didSet {
            
            if shouldIgnoreBottomLayoutGuide == oldValue {
                return
            }
            
            updateScrollViewLayout()
        }
    }
    
    // MARK: Configuration
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupScrollViewLayout()
        setupContentViewLayout()
    }
    
    private func setupScrollViewLayout() {
        view.addSubview(scrollView)
        
        updateScrollViewLayout()
    }
    
    private func updateScrollViewLayout() {
        scrollView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            
            if shouldIgnoreTopLayoutGuide {
                make.top.equalToSuperview()
            } else {
                make.top.safeEqualToTop(of: self)
            }
            
            if shouldIgnoreBottomLayoutGuide {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.safeEqualToBottom(of: self)
            }
        }
    }
    
    private func setupContentViewLayout() {
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.leading.trailing.equalTo(view)
        }
    }
}
