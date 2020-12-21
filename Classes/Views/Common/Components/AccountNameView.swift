//
//  AccountNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupNameLabelLayout()
    }
}

extension AccountNameView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension AccountNameView {
    func setAccountImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setAccountName(_ name: String?) {
        nameLabel.text = name
    }
    
    func bind(_ viewModel: AccountNameViewModel) {
        imageView.image = viewModel.image
        nameLabel.text = viewModel.name
    }
}

extension AccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
