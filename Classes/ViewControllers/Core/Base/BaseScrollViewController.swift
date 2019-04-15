//
//  BaseScrollViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

protocol TouchDetectingScrollViewDelegate: NSObjectProtocol {
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint)
}

class TouchDetectingScrollView: UIScrollView {
    
    weak var touchDetectingDelegate: TouchDetectingScrollViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        touchDetectingDelegate?.scrollViewDidDetectTouchEvent(scrollView: self, in: point)
        
        return super.hitTest(point, with: event)
    }
}

class BaseScrollViewController: BaseViewController {
    
    // MARK: Components
    
    private(set) lazy var scrollView: TouchDetectingScrollView = {
        let scrollView = TouchDetectingScrollView()
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
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupContentViewLayout() {
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.leading.trailing.equalTo(view)
            make.height.equalToSuperview().priority(.low)
        }
    }
}
