//
//  ContactContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder"))
        imageView.backgroundColor = SharedColors.primaryBackground
        imageView.layer.cornerRadius = layout.current.imageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private(set) lazy var addressLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.gray500)
            .withAlignment(.left)
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
    }()
    
    private(set) lazy var qrDisplayButton: UIButton = {
        let button = UIButton(type: .custom).withImage(img("icon-qr", isTemplate: true)).withBackgroundColor(SharedColors.primaryBackground)
        button.layer.cornerRadius = 20.0
        button.tintColor = SharedColors.gray600
        return button
    }()
    
    weak var delegate: ContactContextViewDelegate?
    
    override func setListeners() {
        qrDisplayButton.addTarget(self, action: #selector(notifyDelegateToQRDisplayButtonTapped), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupUserImageViewLayout()
        setupNameLabelLayout()
        setupAddressLabelLayout()
        setupQRDisplayButtonLayout()
    }
}

extension ContactContextView {
    @objc
    private func notifyDelegateToQRDisplayButtonTapped() {
        delegate?.contactContextViewDidTapQRDisplayButton(self)
    }
}

extension ContactContextView {
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.height.equalTo(layout.current.imageSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userImageView.snp.centerY).inset(-layout.current.minimumOffset)
            make.leading.equalTo(userImageView.snp.trailing).offset(layout.current.labelLeftInset)
        }
    }
    
    private func setupAddressLabelLayout() {
        addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.centerY).offset(layout.current.minimumOffset)
            make.leading.equalTo(nameLabel)
        }
    }
    
    private func setupQRDisplayButtonLayout() {
        addSubview(qrDisplayButton)
        
        qrDisplayButton.snp.makeConstraints { make in
            make.width.height.equalTo(layout.current.buttonSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(userImageView)
            make.leading.greaterThanOrEqualTo(addressLabel.snp.trailing).offset(layout.current.minimumOffset)
        }
    }
}

extension ContactContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 10.0
        let imageSize: CGFloat = 44.0
        let buttonSize: CGFloat = 40.0
        let labelLeftInset: CGFloat = 12.0
        let minimumOffset: CGFloat = 4.0
    }
}

protocol ContactContextViewDelegate: class {
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView)
}
