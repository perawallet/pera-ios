//
//  QRBottomInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class QRBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-main-button"))
            .withTitle("title-approve".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.ButtonText.primary)
    }()
    
    private(set) lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-cancel".localized)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.ButtonText.secondary)
    }()
    
    weak var delegate: QRBottomInformationViewDelegate?
    
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

extension QRBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(actionButton.snp.bottom).offset(layout.current.buttonOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension QRBottomInformationView {
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.qrBottomInformationViewDidTapCancelButton(self)
    }
    
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.qrBottomInformationViewDidTapActionButton(self)
    }
}

extension QRBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonOffset: CGFloat = 12.0
        let verticalInset: CGFloat = 28.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol QRBottomInformationViewDelegate: class {
    func qrBottomInformationViewDidTapCancelButton(_ qrBottomInformationView: QRBottomInformationView)
    func qrBottomInformationViewDidTapActionButton(_ qrBottomInformationView: QRBottomInformationView)
}
