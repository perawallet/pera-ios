//
//  BaseScrollViewController.swift

import UIKit
import SnapKit

class BaseScrollViewController: BaseViewController {
    
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
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupScrollViewLayout()
        setupContentViewLayout()
    }
}

extension BaseScrollViewController {
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
