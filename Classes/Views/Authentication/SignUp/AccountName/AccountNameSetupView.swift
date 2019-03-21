//
//  AccountNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountNameSetupViewDelegate: class {
    
    func accountNameSetupViewDidTapNextButton(_ accountNameSetupView: AccountNameSetupView)
}

class AccountNameSetupView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 220.0
        let buttonBottomInset: CGFloat = 15.0
        let buttonTopInset: CGFloat = 120.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountNameInputView = SingleLineFieldView()
    
    private(set) lazy var nextButton: MainButton = {
        let button = MainButton(title: "title-next".localized)
        return button
    }()
    
    weak var delegate: AccountNameSetupViewDelegate?
    
    // MARK: Configuration
    
    override func configureAppearance() {
        backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    override func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToNextButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountNameInputViewLayout()
        setupNextButtonLayout()
    }
    
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupNextButtonLayout() {
        addSubview(nextButton)
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(accountNameInputView.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.buttonBottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToNextButtonTapped() {
        delegate?.accountNameSetupViewDidTapNextButton(self)
    }
}
