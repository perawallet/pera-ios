//
//  AccountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var accountTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-algo-black"))
        imageView.isHidden = true
        return imageView
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupDetailLabelLayout()
        setupImageViewLayout()
        setupAccountTypeImageViewLayout()
        setupNameLabelLayout()
    }
}

extension AccountContextView {
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(detailLabel.snp.leading).offset(layout.current.imageViewOffset)
        }
    }
    
    private func setupAccountTypeImageViewLayout() {
        addSubview(accountTypeImageView)
        
        accountTypeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(accountTypeImageView.snp.trailing).offset(layout.current.nameLabelInset).priority(.required)
            make.leading.equalToSuperview().inset(layout.current.defaultInset).priority(.medium)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(imageView.snp.leading)
        }
    }
}

extension AccountContextView {
    func setAccountTypeImage(_ image: UIImage?, hidden isHidden: Bool) {
        if isHidden {
            accountTypeImageView.removeFromSuperview()
        } else {
            accountTypeImageView.isHidden = false
            accountTypeImageView.image = image
        }
    }
}

extension AccountContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let imageViewOffset: CGFloat = -2.0
        let nameLabelInset: CGFloat = 12.0
    }
}
