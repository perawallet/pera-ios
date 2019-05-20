//
//  AuctionPrerequirementElementView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionPrerequirementElementView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 22.0 * horizontalScale
        let titleInset: CGFloat = 10.0 * horizontalScale
        let subtitleTopInset: CGFloat = 1.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var numberLabel = NumberLabel()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 14.0 * verticalScale)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0 * verticalScale)))
            .withTextColor(SharedColors.softGray)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupNumberLabelLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
    
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(layout.current.titleInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(numberLabel)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.bottom.equalToSuperview()
        }
    }
}
