//
//  DefaultAlertView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol DefaultAlertViewDelegate: class {
    
    func defaultAlertViewDidTapDoneButton(_ alertView: DefaultAlertView)
}

class DefaultAlertView: AlertView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 25.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var doneButton: MainButton = {
        let button = MainButton(title: "title-ok".localized)
        return button
    }()
    
    weak var delegate: DefaultAlertViewDelegate?
    
    // MARK: Listeners
    
    override func setListeners() {
        doneButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupDoneButtonLayout()
    }
    
    private func setupDoneButtonLayout() {
        addSubview(doneButton)
        
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    @objc
    private func notifyDelegateToDoneButtonTapped() {
        delegate?.defaultAlertViewDidTapDoneButton(self)
    }
}
