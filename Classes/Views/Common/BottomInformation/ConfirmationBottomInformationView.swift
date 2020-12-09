//
//  ConfirmationBottomInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ConfirmationBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(Colors.ButtonText.primary)
    }()
    
    weak var delegate: ConfirmationBottomInformationViewDelegate?
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupActionButtonLayout()
    }
}

extension ConfirmationBottomInformationView {
    @objc
    private func notifyDelegateToDoneButtonTapped() {
        delegate?.confirmationBottomInformationViewDidTapActionButton(self)
    }
}

extension ConfirmationBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension ConfirmationBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let buttonHorizontalInset: CGFloat = 32.0
    }
}

protocol ConfirmationBottomInformationViewDelegate: class {
    func confirmationBottomInformationViewDidTapActionButton(_ confirmationBottomInformationView: ConfirmationBottomInformationView)
}
