//
//  PassphraseDisplayView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol PassphraseDisplayViewDelegate: class {
    
    func passphraseDisplayViewDidTapShareButton(_ passphraseDisplayView: PassphraseDisplayView)
    func passphraseDisplayViewDidTapDoneButton(_ passphraseDisplayView: PassphraseDisplayView)
}

class PassphraseDisplayView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 31.0
        let titleHorizontalInset: CGFloat = 25.0
        let containerHorizontalInset: CGFloat = 10.0
        let containerTopInset: CGFloat = 37.0
        let passphraseLabelHorizontalInset: CGFloat = 23.0
        let passphraseLabelTopInset: CGFloat = 39.0
        let shareButtonHorizontalInset: CGFloat = 18.0
        let buttonTopInset: CGFloat = 34.0
        let buttonBottomInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 22.0)))
            .withText("view-pass-phrase-title".localized)
    }()
    
    private lazy var passphraseContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var passphraseLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 17.0)))
    }()
    
    private(set) lazy var shareButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 4.5, y: 0.0), title: CGPoint(x: -4.5, y: 0.0))
        
        let button = AlignedButton(style: .imageRight(positions))
        button.setImage(img("icon-share"), for: .normal)
        button.setTitle("title-share".localized, for: .normal)
        button.setTitleColor(SharedColors.blue, for: .normal)
        button.titleLabel?.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))
        return button
    }()
    
    private lazy var okButton: MainButton = {
        let button = MainButton(title: "title-ok".localized)
        return button
    }()
    
    weak var delegate: PassphraseDisplayViewDelegate?
    
    // MARK: Configuration
    
    override func configureAppearance() {
        backgroundColor = SharedColors.warmWhite
        layer.cornerRadius = 10.0
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(notifyDelegateToOkButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupPassphraseContainerViewLayout()
        setupPassphraseLabelLayout()
        setupShareButtonLayout()
        setupOkButtonLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupPassphraseContainerViewLayout() {
        addSubview(passphraseContainerView)
        
        passphraseContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.containerHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.containerTopInset)
        }
    }
    
    private func setupPassphraseLabelLayout() {
        passphraseContainerView.addSubview(passphraseLabel)
        
        passphraseLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.passphraseLabelHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.passphraseLabelTopInset)
        }
    }
    
    private func setupShareButtonLayout() {
        passphraseContainerView.addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseLabel.snp.bottom).offset(layout.current.passphraseLabelHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.passphraseLabelHorizontalInset)
            make.trailing.equalToSuperview().inset(layout.current.shareButtonHorizontalInset)
        }
    }
    
    private func setupOkButtonLayout() {
        addSubview(okButton)
        
        okButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passphraseContainerView.snp.bottom).offset(layout.current.buttonTopInset)
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToShareButtonTapped() {
        delegate?.passphraseDisplayViewDidTapShareButton(self)
    }
    
    @objc
    func notifyDelegateToOkButtonTapped() {
        delegate?.passphraseDisplayViewDidTapDoneButton(self)
    }
}
