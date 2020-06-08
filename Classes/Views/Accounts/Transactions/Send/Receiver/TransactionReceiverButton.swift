//
//  TransactionReceiverButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionReceiverButton: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var containerView = UIView()
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(SharedColors.gray800)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    init(title: String, image: UIImage?) {
        super.init()
        titleLabel.text = title
        imageView.image = image
    }

    override func configureAppearance() {
        containerView.backgroundColor = SharedColors.secondaryBackground
        containerView.isUserInteractionEnabled = false
        containerView.layer.cornerRadius = 12.0
        containerView.applySmallShadow()
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupImageViewLayout()
        setupTitleLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.updateShadowLayoutWhenViewDidLayoutSubviews()
    }
}

extension TransactionReceiverButton {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(containerView.snp.height).multipliedBy(1.05)
        }
    }
    
    private func setupImageViewLayout() {
        containerView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.centerY.equalToSuperview().offset(layout.current.imageViewCenterOffset)
        }
    }
    
    private func setupTitleLabelLayout() {
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleOffset)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension TransactionReceiverButton {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleOffset: CGFloat = 8.0
        let imageViewCenterOffset: CGFloat = -12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
