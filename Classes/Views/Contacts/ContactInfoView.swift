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
    func contactInfoViewDidEditContactButton(_ contactInfoView: ContactInfoView)
}

class ContactInfoView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewHeight: CGFloat = 333.0
        let bottomInset: CGFloat = 20.0
        let topInset: CGFloat = 24.0
        let minimumInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(isEditable: false)
        return view
    }()
    
    private(set) lazy var editContactButton: MainButton = {
        let button = MainButton(title: "contacts-edit-button".localized)
        return button
    }()
    
    weak var delegate: ContactInfoViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    override func setListeners() {
        editContactButton.addTarget(self, action: #selector(notifyDelegateToEditContactButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupEditContactButtonLayout()
    }
    
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(layout.current.topInset)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupEditContactButtonLayout() {
        addSubview(editContactButton)
        
        editContactButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(userInformationView.snp.bottom).offset(layout.current.minimumInset)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToEditContactButtonTapped() {
        delegate?.contactInfoViewDidEditContactButton(self)
    }
}

extension ContactInfoView: UserInformationViewDelegate {
    
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.contactInfoViewDidTapQRCodeButton(self)
    }
}
