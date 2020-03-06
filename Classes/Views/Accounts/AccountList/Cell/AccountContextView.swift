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
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withTextColor(SharedColors.black)
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
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 15.0)))
            .withTextColor(SharedColors.purple)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupDetailLabelLayout()
        setupImageViewLayout()
        setupAccountTypeImageViewLayout()
        setupNameLabelLayout()
        setupSeparatorViewLayout()
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
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
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
        let defaultInset: CGFloat = 25.0
        let imageViewOffset: CGFloat = -2.0
        let separatorHeight: CGFloat = 1.0
        let nameLabelInset: CGFloat = 11.0
    }
}

extension AccountContextView {
    private enum Colors {
        static let separatorColor = rgb(0.91, 0.91, 0.92)
    }
}
