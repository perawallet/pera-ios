//
//  QRAlertView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

protocol QRAlertViewDelegate: class {
    func qRAlertViewDidTapCancelButton(_ alertView: QRAlertView)
    func qrAlertViewDidTapActionButton(_ alertView: QRAlertView)
}

class QRAlertView: AlertView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-main-button"))
            .withTitle("title-approve".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withTitleColor(UIColor.white)
    }()
    
    private(set) lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withTitleColor(SharedColors.black)
    }()
    
    weak var delegate: QRAlertViewDelegate?
    
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

extension QRAlertView {
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
            make.bottom.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension QRAlertView {
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.qRAlertViewDidTapCancelButton(self)
    }
    
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.qrAlertViewDidTapActionButton(self)
    }
}

extension QRAlertView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let buttonOffset: CGFloat = 10.0
        let verticalInset: CGFloat = 35.0
    }
}
