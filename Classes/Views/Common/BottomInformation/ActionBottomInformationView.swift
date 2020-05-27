//
//  ActionBottomInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ActionBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(SharedColors.primaryButtonTitle)
            .withAlignment(.center)
    }()
    
    private(set) lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(SharedColors.primaryText)
            .withAlignment(.center)
    }()
    
    weak var delegate: ActionBottomInformationViewDelegate?
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupActionButtonLayout()
        setupCancelButtonLayout()
    }
}

extension ActionBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(actionButton.snp.bottom).offset(layout.current.cancelButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension ActionBottomInformationView {
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.actionBottomInformationViewDidTapActionButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.actionBottomInformationViewDidTapCancelButton(self)
    }
}

extension ActionBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let cancelButtonTopInset: CGFloat = 12.0
        let buttonHorizontalInset: CGFloat = 32.0
    }
}

protocol ActionBottomInformationViewDelegate: class {
    func actionBottomInformationViewDidTapActionButton(_ actionBottomInformationView: ActionBottomInformationView)
    func actionBottomInformationViewDidTapCancelButton(_ actionBottomInformationView: ActionBottomInformationView)
}
