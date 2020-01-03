//
//  ContactAssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactAssetViewDelegate: class {
    func contactAssetViewDidTapSendButton(_ contactAssetView: ContactAssetView)
}

class ContactAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ContactAssetViewDelegate?
    
    private(set) lazy var assetNameView: AssetNameView = {
        let view = AssetNameView()
        view.idLabel.isHidden = false
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-send-small"))
            .withImage(img("icon-arrow-up"))
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAssetNameViewLayout()
        setupSendButtonLayout()
    }
}

extension ContactAssetView {
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.contactAssetViewDidTapSendButton(self)
    }
}

extension ContactAssetView {
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonInset)
            make.centerY.equalToSuperview()
        }
    }
}

extension ContactAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 15.0
        let buttonInset: CGFloat = 17.0
    }
}
