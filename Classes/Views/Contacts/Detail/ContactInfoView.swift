//
//  ContactInfoView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactInfoViewDelegate: class {
    
    func contactInfoViewDidTapQRCodeButton(_ contactInfoView: ContactInfoView)
    func contactInfoViewDidTapSendButton(_ contactInfoView: ContactInfoView)
    func contactInfoViewDidEditContactButton(_ contactInfoView: ContactInfoView)
    func contactInfoViewDidDeleteContactButton(_ contactInfoView: ContactInfoView)
}

class ContactInfoView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewHeight: CGFloat = 333.0
        let bottomInset: CGFloat = 15.0
        let minimumInset: CGFloat = 10.0
        let backgroundViewHeight: CGFloat = 113.0
        let buttonInset: CGFloat = 24.0
        let sendButtonTopInset: CGFloat = 40.0
        let deleteButtonTopInset: CGFloat = 10.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private(set) lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(isEditable: false)
        return view
    }()
    
    private(set) lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(.white)
            .withAttributedTitle(
                "title-send-algos-uppercase".localized.attributed([
                    .letterSpacing(1.20),
                    .textColor(.white)
                ])
            )
            .withTitle("title-send".localized)
            .withBackgroundImage(img("bg-button-orange"))
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withImage(img("icon-arrow-up"))
            .withImageEdgeInsets(UIEdgeInsets(top: 0, left: 180.0 - UIScreen.main.bounds.width, bottom: 0.0, right: 0.0))
            .withTitleEdgeInsets(UIEdgeInsets(top: 0, left: -21.0, bottom: 0.0, right: 0.0))
    }()
    
    private(set) lazy var editContactButton: MainButton = {
        let button = MainButton(title: "contacts-edit-button".localized)
        button.setBackgroundImage(img("bg-button-navy"), for: .normal)
        return button
    }()
    
    private(set) lazy var deleteContactButton: MainButton = {
        let button = MainButton(title: "contacts-delete-contact".localized)
        button.setBackgroundImage(img("bg-black-button-big"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    weak var delegate: ContactInfoViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        editContactButton.addTarget(self, action: #selector(notifyDelegateToEditContactButtonTapped), for: .touchUpInside)
        deleteContactButton.addTarget(self, action: #selector(notifyDelegateToDeleteContactButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupSendButtonLayout()
        setupEditContactButtonLayout()
        setupDeleteContactButtonLayout()
    }
    
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.sendButtonTopInset)
        }
    }
    
    private func setupEditContactButtonLayout() {
        addSubview(editContactButton)
        
        editContactButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(sendButton.snp.bottom).offset(layout.current.minimumInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    private func setupDeleteContactButtonLayout() {
        addSubview(deleteContactButton)
        
        deleteContactButton.snp.makeConstraints { make in
            make.top.equalTo(editContactButton.snp.bottom).offset(layout.current.buttonInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    // MARK: Actions

    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.contactInfoViewDidTapSendButton(self)
    }
    
    @objc
    private func notifyDelegateToEditContactButtonTapped() {
        delegate?.contactInfoViewDidEditContactButton(self)
    }
    
    @objc
    private func notifyDelegateToDeleteContactButtonTapped() {
        delegate?.contactInfoViewDidDeleteContactButton(self)
    }
}

extension ContactInfoView: UserInformationViewDelegate {
    
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.contactInfoViewDidTapQRCodeButton(self)
    }
}
