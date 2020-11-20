//
//  NoInternetConnectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NoInternetConnectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView(image: img("icon-no-internet-connection"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
            .withText("internet-connection-error-title".localized)
            .withLine(.single)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.tertiary)
            .withAlignment(.center)
            .withText("internet-connection-error-detail".localized)
            .withLine(.contained)
    }()
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
}

extension NoInternetConnectionView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
}

extension NoInternetConnectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 24.0
        let subtitleTopInset: CGFloat = 12.0
        let subtitleHorizontalInset: CGFloat = 40.0
    }
}
