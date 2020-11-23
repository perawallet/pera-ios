//
//  AssetFooterView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountFooterViewDelegate?
    
    private lazy var containerView = UIView()
    
    private lazy var addAssetButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.setImage(img("icon-plus-primary"), for: .normal)
        button.setTitle("accounts-add-new".localized, for: .normal)
        button.setTitleColor(SharedColors.tertiaryText, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = SharedColors.secondaryBackground
        containerView.layer.cornerRadius = 12.0
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupAddAssetButtonLayout()
    }
    
    override func setListeners() {
        addAssetButton.addTarget(self, action: #selector(notifyDelegateToAddAssetButtonTapped), for: .touchUpInside)
    }
}

extension AccountFooterView {
    @objc
    private func notifyDelegateToAddAssetButtonTapped() {
        delegate?.accountFooterViewDidTapAddAssetButton(self)
    }
}

extension AccountFooterView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.containerHeight)
        }
    }
    
    private func setupAddAssetButtonLayout() {
        containerView.addSubview(addAssetButton)
        
        addAssetButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension AccountFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let containerHeight: CGFloat = 52.0
        let bottomInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol AccountFooterViewDelegate: class {
    func accountFooterViewDidTapAddAssetButton(_ accountFooterView: AccountFooterView)
}
