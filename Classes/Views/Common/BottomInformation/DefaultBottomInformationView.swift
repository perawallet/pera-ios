//
//  DefaultBottomInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DefaultBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(SharedColors.primaryButtonTitle)
    }()
    
    weak var delegate: DefaultBottomInformationViewDelegate?
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupActionButtonLayout()
    }
}

extension DefaultBottomInformationView {
    @objc
    private func notifyDelegateToDoneButtonTapped() {
        delegate?.defaultBottomInformationViewDidTapActionButton(self)
    }
}

extension DefaultBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension DefaultBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let buttonHorizontalInset: CGFloat = 32.0
    }
}

protocol DefaultBottomInformationViewDelegate: class {
    func defaultBottomInformationViewDidTapActionButton(_ defaultBottomInformationView: DefaultBottomInformationView)
}
