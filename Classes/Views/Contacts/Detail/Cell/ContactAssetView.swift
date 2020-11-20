//
//  ContactAssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ContactAssetViewDelegate?
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-asset-contact-cell"))
    
    private(set) lazy var assetNameView = AssetNameView()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
            .withBackgroundImage(img("bg-send-small"))
            .withImage(img("icon-arrow-up-24"))
            .withAlignment(.center)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupSendButtonLayout()
        setupAssetNameViewLayout()
    }
}

extension ContactAssetView {
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.contactAssetViewDidTapSendButton(self)
    }
}

extension ContactAssetView {
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(sendButton.snp.leading).offset(-layout.current.mininmumOffset)
        }
    }
}

extension ContactAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let mininmumOffset: CGFloat = 4.0
    }
}

protocol ContactAssetViewDelegate: class {
    func contactAssetViewDidTapSendButton(_ contactAssetView: ContactAssetView)
}
