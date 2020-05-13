//
//  AccountsEmptyStateView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class EmptyStateView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var imageView = UIImageView(image: image)
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withText(title)
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAttributedText(subtitle.attributed([.lineSpacing(1.2)]))
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.gray800)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()
    
    private let image: UIImage?
    private let title: String
    private let subtitle: String
    
    init(image: UIImage?, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
}

extension EmptyStateView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension EmptyStateView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 120.0
        let horizontalInset: CGFloat = 40.0
        let titleTopInset: CGFloat = 24.0
        let subtitleTopInset: CGFloat = 12.0
    }
}
