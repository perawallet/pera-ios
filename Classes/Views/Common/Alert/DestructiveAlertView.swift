//
//  DestructiveAlertView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol DestructiveAlertViewDelegate: class {
    
    func destructiveAlertViewDidTapCancelButton(_ alertView: DestructiveAlertView)
    func destructiveAlertViewDidTapActionButton(_ alertView: DestructiveAlertView)
}

class DestructiveAlertView: AlertView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let buttonMinimumSpacing: CGFloat = 5.0
        let buttonWidth: CGFloat = 135.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withBackgroundImage(img("bg-cancel-button"))
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
            .withTitleColor(SharedColors.black)
    }()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-remove-button"))
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
            .withTitleColor(SharedColors.black)
    }()
    
    weak var delegate: DestructiveAlertViewDelegate?
    
    // MARK: Listeners
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelButtonTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupCancelButtonLayout()
        setupActionButtonLayout()
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.defaultInset)
            make.leading.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton)
            make.width.equalTo(layout.current.buttonWidth)
            make.leading.greaterThanOrEqualTo(cancelButton.snp.trailing).offset(layout.current.buttonMinimumSpacing)
            make.trailing.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.destructiveAlertViewDidTapCancelButton(self)
    }
    
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.destructiveAlertViewDidTapActionButton(self)
    }
}
