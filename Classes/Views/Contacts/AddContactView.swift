//
//  AddContactView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AddContactViewDelegate: class {
    
    func addContactViewDidTapAddContactButton(_ addContactView: AddContactView)
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView)
    func addContactViewDidTapQRCodeButton(_ addContactView: AddContactView)
}

class AddContactView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewHeight: CGFloat = 333.0
        let topInset: CGFloat = 24.0
        let bottomInset: CGFloat = 20.0
        let minimumInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var userInformationView: UserInformationView = {
        let view = UserInformationView()
        return view
    }()
    
    private(set) lazy var addContactButton: MainButton = {
        let button = MainButton(title: "contacts-add-button".localized)
        return button
    }()
    
    weak var delegate: AddContactViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        addContactButton.addTarget(self, action: #selector(notifyDelegateToAddButtonTapped), for: .touchUpInside)
    }
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupAddButtonLayout()
    }
    
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(layout.current.topInset)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addContactButton)
        
        addContactButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(userInformationView.snp.bottom).offset(layout.current.minimumInset)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToAddButtonTapped() {
        delegate?.addContactViewDidTapAddContactButton(self)
    }
}

// MARK: UserInformationViewDelegate

extension AddContactView: UserInformationViewDelegate {
    
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
        delegate?.addContactViewDidTapAddImageButton(self)
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.addContactViewDidTapQRCodeButton(self)
    }
}
