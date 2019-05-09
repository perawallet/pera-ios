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
        let bottomInset: CGFloat = 20.0
        let topInset: CGFloat = 24.0
        let minimumInset: CGFloat = 10.0
        let backgroundViewHeight: CGFloat = 113.0
        let buttonWidth: CGFloat = 160.0
        let separatorHeight: CGFloat = 1.0
        let buttonInset: CGFloat = 15.0
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
    
    private lazy var sendBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.black)
            .withTitle("title-send".localized)
            .withBackgroundImage(img("bg-blue-small"))
            .withAlignment(.center)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var editContactButton: MainButton = {
        let button = MainButton(title: "contacts-edit-button".localized)
        return button
    }()
    
    private(set) lazy var deleteContactButton: MainButton = {
        let button = MainButton(title: "contacts-delete-contact".localized)
        button.setBackgroundImage(img("bg-button-big-red"), for: .normal)
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
        setupSendBackgroundViewLayout()
        setupSendButtonLayout()
        setupSeparatorViewLayout()
        setupEditContactButtonLayout()
        setupDeleteContactButtonLayout()
    }
    
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(layout.current.topInset)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupSendBackgroundViewLayout() {
        addSubview(sendBackgroundView)
        
        sendBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(userInformationView.snp.bottom)
            make.height.equalTo(layout.current.backgroundViewHeight)
        }
    }
    
    private func setupSendButtonLayout() {
        sendBackgroundView.addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupSeparatorViewLayout() {
        sendBackgroundView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupEditContactButtonLayout() {
        addSubview(editContactButton)
        
        editContactButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(sendBackgroundView.snp.bottom).offset(layout.current.minimumInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupDeleteContactButtonLayout() {
        addSubview(deleteContactButton)
        
        deleteContactButton.snp.makeConstraints { make in
            make.top.equalTo(editContactButton.snp.bottom).offset(layout.current.buttonInset)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(layout.current.bottomInset)
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
