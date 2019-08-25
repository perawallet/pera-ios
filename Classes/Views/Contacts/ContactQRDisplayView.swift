//
//  ContactQRDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactQRDisplayViewDelegate: class {
    
    func contactQRDisplayViewDidTapShareButton(_ contactQRDisplayView: ContactQRDisplayView)
    func contactQRDisplayViewDidTapCloseButton(_ contactQRDisplayView: ContactQRDisplayView)
}

class ContactQRDisplayView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewSize: CGFloat = 50.0 * verticalScale
        let verticalInset: CGFloat = 38.0 * verticalScale
        let shareButtonTopInset: CGFloat = 10.0 * verticalScale
        let shareButtonSize = CGSize(width: 135.0, height: 44.0)
        let selectableLabelTopInset: CGFloat = 16.0 * verticalScale
        let selectableLabelHorizontalInset: CGFloat = 10.0
        let horizontalInset: CGFloat = 25.0
        let nameLabelInset: CGFloat = 13.0 * verticalScale
        let qrViewTopInset: CGFloat = 25.0 * verticalScale
        let addressLabelInset: CGFloat = 30.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let labelBackgroundColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder"))
        imageView.backgroundColor = Colors.labelBackgroundColor
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
    
    private(set) lazy var shareButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-purple-button"))
            .withImage(img("icon-share", isTemplate: true))
            .withTitle("title-share".localized)
            .withTitleColor(UIColor.white)
            .withTintColor(UIColor.white)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withImageEdgeInsets(UIEdgeInsets(top: 0, left: -10.0, bottom: 0, right: 0))
            .withTitleEdgeInsets(UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 0))
    }()
    
    private(set) lazy var qrSelectableLabel: QRSelectableLabel = {
        let qrSelectableLabel = QRSelectableLabel()
        qrSelectableLabel.delegate = self
        qrSelectableLabel.containerView.backgroundColor = Colors.labelBackgroundColor
        qrSelectableLabel.label.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        return qrSelectableLabel
    }()
    
    private(set) lazy var closeButton: MainButton = {
        let button = MainButton(title: "title-close".localized)
        button.setBackgroundImage(img("bg-black-button-big"), for: .normal)
        return button
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
        backgroundColor = .white
        layer.cornerRadius = 10.0
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserImageViewLayout()
        setupUserNameLabelLayout()
        setupQRDisplayViewLayout()
        setupShareButtonLayout()
        setupQrSelectableLabelLayout()
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
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(layout.current.shareButtonTopInset)
            make.size.equalTo(layout.current.shareButtonSize)
            make.centerX.equalTo(qrView)
        }
    }
    
    private func setupQrSelectableLabelLayout() {
        addSubview(qrSelectableLabel)
        
        qrSelectableLabel.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(layout.current.selectableLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.selectableLabelHorizontalInset)
        }
    }
    
    private func setupCloseButtonLayout() {
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(qrSelectableLabel.snp.bottom).offset(layout.current.addressLabelInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToCloseButtonTapped() {
        delegate?.contactQRDisplayViewDidTapCloseButton(self)
    }
    
    @objc
    private func notifyDelegateToShareButtonTapped() {
        delegate?.contactQRDisplayViewDidTapShareButton(self)
    }
}

// MARK: - QRSelectableLabelDelegate

extension ContactQRDisplayView: QRSelectableLabelDelegate {
    
    func qrSelectableLabel(_ qrSelectableLabel: QRSelectableLabel, didTapText text: String) {
        UIPasteboard.general.string = text
    }
}
