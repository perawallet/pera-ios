//
//  ContactContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactContextViewDelegate: class {
    
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView)
}

class ContactContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 15.0
        let imageSize: CGFloat = 50.0
        let labelCenterOffset: CGFloat = 5.0
        let labelLeftInset: CGFloat = 14.0
        let verticalInset: CGFloat = 20.0
        let buttonSize: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder"))
        imageView.backgroundColor = SharedColors.warmWhite
        imageView.layer.cornerRadius = layout.current.imageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var addressLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.darkGray)
            .withAlignment(.left)
            .withLine(.single)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
    }()
    
    private(set) lazy var qrDisplayButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-qr-gray"))
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    weak var delegate: ContactContextViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        qrDisplayButton.addTarget(self, action: #selector(notifyDelegateToQRDisplayButtonTapped), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserImageViewLayout()
        setupNameLabelLayout()
        setupAddressLabelLayout()
        setupQRDisplayButtonLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.height.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userImageView.snp.centerY).inset(-layout.current.labelCenterOffset)
            make.leading.equalTo(userImageView.snp.trailing).offset(layout.current.labelLeftInset)
        }
    }
    
    private func setupAddressLabelLayout() {
        addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.centerY).offset(layout.current.labelCenterOffset)
            make.leading.equalTo(nameLabel)
        }
    }
    
    private func setupQRDisplayButtonLayout() {
        addSubview(qrDisplayButton)
        
        qrDisplayButton.snp.makeConstraints { make in
            make.width.height.equalTo(layout.current.buttonSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(addressLabel)
            make.leading.equalTo(addressLabel.snp.trailing).offset(layout.current.horizontalInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToQRDisplayButtonTapped() {
        delegate?.contactContextViewDidTapQRDisplayButton(self)
    }
}
