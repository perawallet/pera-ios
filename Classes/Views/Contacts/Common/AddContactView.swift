//
//  AddContactView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AddContactView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var userInformationView = UserInformationView()
    
    private(set) lazy var addContactButton = MainButton(title: "contacts-add".localized)
    
    private(set) lazy var deleteContactButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 0.0), title: CGPoint(x: 4.0, y: 0.0))
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-trash", isTemplate: true), for: .normal)
        button.tintColor = SharedColors.red
        button.setTitle("contacts-delete-contact".localized, for: .normal)
        button.setTitleColor(SharedColors.red, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        return button
    }()
    
    weak var delegate: AddContactViewDelegate?
    
    override func setListeners() {
        addContactButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
        deleteContactButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
    }
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupAddButtonLayout()
        setupDeleteContactButtonLayout()
    }
}

extension AddContactView {
    @objc
    private func notifyDelegateToHandleAction() {
        delegate?.addContactViewDidTapActionButton(self)
    }
}

extension AddContactView {
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addContactButton)
        
        addContactButton.snp.makeConstraints { make in
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    private func setupDeleteContactButtonLayout() {
        addSubview(deleteContactButton)
        
        deleteContactButton.snp.makeConstraints { make in
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
            make.size.equalTo(layout.current.deleteButtonSize)
        }
    }
}

extension AddContactView: UserInformationViewDelegate {
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
        delegate?.addContactViewDidTapAddImageButton(self)
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.addContactViewDidTapQRCodeButton(self)
    }
}

extension AddContactView {
    func setUserActionButtonIcon(_ image: UIImage?) {
        userInformationView.setAddButtonIcon(image)
    }
}

extension AddContactView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 15.0
        let topInset: CGFloat = 28.0
        let buttonHorizontalInset: CGFloat = 20.0
        let deleteButtonSize = CGSize(width: 145.0, height: 44.0)
    }
}

protocol AddContactViewDelegate: class {
    func addContactViewDidTapActionButton(_ addContactView: AddContactView)
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView)
    func addContactViewDidTapQRCodeButton(_ addContactView: AddContactView)
}
