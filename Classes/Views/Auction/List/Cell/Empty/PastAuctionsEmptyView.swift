//
//  PastAuctionsEmptyView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PastAuctionsEmptyView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelTopInset: CGFloat = 82.0 * verticalScale
        let imageViewSize = CGSize(width: 300.0 * horizontalScale, height: 147.0 * verticalScale)
        let defaultInset: CGFloat = 16.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withText("auction-past-empty-title".localized)
    }()
    
    private lazy var imageView = UIImageView(image: img("img-past-auctions-empty"))
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTitleLabelLayout()
        setupImageViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageViewSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.defaultInset)
        }
    }
}
