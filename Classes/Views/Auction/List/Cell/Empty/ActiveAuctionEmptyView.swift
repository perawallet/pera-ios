//
//  ActiveAuctionEmptyView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ActiveAuctionEmptyView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelTopInset: CGFloat = 60.0 * verticalScale
        let imageViewSize = CGSize(width: 300.0 * horizontalScale, height: 125.0 * verticalScale)
        let defaultInset: CGFloat = 20.0 * verticalScale
        let containerHeight: CGFloat = 293.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withText("auction-empty-title".localized)
    }()
    
    private lazy var imageView = UIImageView(image: img("img-active-auction-empty"))
    
    private lazy var pastAuctionsTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withText("auction-past-auctions".localized)
    }()
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupContainerViewLayout()
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupPastAuctionsTitleLabelLayout()
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.containerHeight)
        }
    }
    
    private func setupTitleLabelLayout() {
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
        }
    }
    
    private func setupImageViewLayout() {
        containerView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageViewSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.defaultInset)
        }
    }
    
    private func setupPastAuctionsTitleLabelLayout() {
        addSubview(pastAuctionsTitleLabel)
        
        pastAuctionsTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.defaultInset)
        }
    }
}
