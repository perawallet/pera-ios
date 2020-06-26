//
//  AssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetViewDelegate?
    
    private(set) lazy var assetNameView: AssetNameView = {
        let view = AssetNameView()
        view.removeId()
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTitleColor(SharedColors.primaryText)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.primaryBackground
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupActionButtonLayout()
        setupAssetNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension AssetView {
    func setActionColor(_ color: UIColor?) {
        actionButton.setTitleColor(color, for: .normal)
    }
    
    func setActionFont(_ font: UIFont?) {
        actionButton.titleLabel?.font = font
    }
    
    func setActionText(_ text: String?) {
        actionButton.setTitle(text, for: .normal)
    }
}

extension AssetView {
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.assetViewDidTapActionButton(self)
    }
}

extension AssetView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-layout.current.assetNameOffet)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension AssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let assetNameOffet: CGFloat = 10.0
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 10.0
    }
}

protocol AssetViewDelegate: class {
    func assetViewDidTapActionButton(_ assetView: AssetView)
}
