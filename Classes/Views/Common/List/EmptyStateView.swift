//
//  AccountsEmptyStateView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class EmptyStateView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleInset: CGFloat = 79.0
        let topImageViewInset: CGFloat = 13.0
        let bottomImageViewInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.montserrat, withWeight: .medium(size: 14.0)))
            .withText(title)
    }()
    
    private lazy var topImageView = UIImageView(image: topImage)
    
    private lazy var bottomImageView = UIImageView(image: bottomImage)
    
    // MARK: Initialization
    
    private let title: String
    private let topImage: UIImage?
    private let bottomImage: UIImage?
    private let alignment: Alignment
    
    init(title: String, topImage: UIImage?, bottomImage: UIImage?, alignment: Alignment = .top) {
        self.title = title
        self.topImage = topImage
        self.bottomImage = bottomImage
        self.alignment = alignment
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        if alignment == .top {
            setupTitleLabelLayout()
            setupTopImageViewLayout()
            setupBottomImageViewLayout()
        } else {
            setupBottomImageViewLayout()
            setupTopImageViewLayout()
            setupTitleLabelLayout()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            
            if alignment == .top {
                make.top.equalToSuperview().inset(layout.current.titleInset)
            } else {
                make.bottom.equalTo(topImageView.snp.top).inset(-layout.current.titleInset)
            }
        }
    }
    
    private func setupTopImageViewLayout() {
        addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            
            if alignment == .top {
                make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.topImageViewInset)
            } else {
                make.bottom.equalTo(bottomImageView.snp.top).offset(-layout.current.topImageViewInset)
            }
        }
    }
    
    private func setupBottomImageViewLayout() {
        addSubview(bottomImageView)
        
        bottomImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            
            if alignment == .top {
                make.top.equalTo(topImageView.snp.bottom).offset(layout.current.bottomImageViewInset)
            } else {
                make.bottom.equalToSuperview().offset(layout.current.bottomImageViewInset)
            }
        }
    }
}

// MARK: Alignment

extension EmptyStateView {
    
    enum Alignment {
        case top
        case bottom
    }
}
