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
    func contactContextViewDidTapSendButton(_ contactContextView: ContactContextView)
}

class ContactContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let imageInset: CGFloat = 30.0
        let separatorInset: CGFloat = 25.0
        let horizontalInset: CGFloat = 15.0
        let imageSize: CGFloat = 40.0
        let labelCenterOffset: CGFloat = 5.0
        let labelLeftInset: CGFloat = 8.0
        let verticalInset: CGFloat = 23.0
        let buttonInternalInset: CGFloat = -20.0
        let buttonSize: CGFloat = 38.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.94, 0.94, 0.94)
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
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
    }()
    
    private(set) lazy var addressLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.softGray)
            .withAlignment(.left)
            .withLine(.single)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
    }()
    
    private(set) lazy var qrDisplayButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-qr-view"))
    }()
    
    private(set) lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-send-small"))
            .withBackgroundColor(.white)
            .withImage(img("icon-arrow-up"))
            .withAlignment(.center)
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
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserImageViewLayout()
        setupNameLabelLayout()
        setupAddressLabelLayout()
        setupSendButtonLayout()
        setupQRDisplayButtonLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.imageInset)
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
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.width.height.equalTo(layout.current.buttonSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupQRDisplayButtonLayout() {
        addSubview(qrDisplayButton)
        
        qrDisplayButton.snp.makeConstraints { make in
            make.width.height.equalTo(layout.current.buttonSize)
            make.trailing.equalTo(sendButton.snp.leading).offset(layout.current.buttonInternalInset)
            make.centerY.equalToSuperview()
            make.leading.equalTo(addressLabel.snp.trailing).offset(layout.current.labelCenterOffset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToQRDisplayButtonTapped() {
        delegate?.contactContextViewDidTapQRDisplayButton(self)
    }
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.contactContextViewDidTapSendButton(self)
    }
}
