//
//  ContactQRDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactQRDisplayViewDelegate: class {
    
    func contactQRDisplayViewDidTapCloseButton(_ contactQRDisplayView: ContactQRDisplayView)
}

class ContactQRDisplayView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewSize: CGFloat = 50.0
        let verticalInset: CGFloat = 38.0
        let horizontalInset: CGFloat = 25.0
        let nameLabelInset: CGFloat = 13.0
        let qrViewTopInset: CGFloat = 25.0
        let addressLabelInset: CGFloat = 30.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder"))
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = layout.current.imageViewSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 15.0)))
    }()
    
    private(set) lazy var qrView: QRView = {
        let qrText = QRText(mode: .address, text: address)
        return QRView(qrText: qrText)
    }()
    
    private(set) lazy var addressLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withAlignment(.center)
            .withLine(.contained)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("bg-main-button"))
            .withTitle("title-close".localized)
            .withTitleColor(SharedColors.purple)
    }()
    
    weak var delegate: ContactQRDisplayViewDelegate?
    
    // MARK: Initialization
    
    private let address: String
    
    init(address: String) {
        self.address = address
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = SharedColors.warmWhite
        layer.cornerRadius = 10.0
    }
    
    override func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserImageViewLayout()
        setupUserNameLabelLayout()
        setupQRDisplayViewLayout()
        setupAddressLabelLayout()
        setupCloseButtonLayout()
    }

    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.width.height.equalTo(layout.current.imageViewSize)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupUserNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
            make.top.equalTo(userImageView.snp.bottom).offset(layout.current.nameLabelInset)
        }
    }
    
    private func setupQRDisplayViewLayout() {
        addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(layout.current.qrViewTopInset)
            make.centerX.equalToSuperview()
            make.height.equalTo(qrView.snp.width)
        }
    }
    
    private func setupAddressLabelLayout() {
        addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(layout.current.addressLabelInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCloseButtonLayout() {
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(layout.current.addressLabelInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToCloseButtonTapped() {
        delegate?.contactQRDisplayViewDidTapCloseButton(self)
    }
}
