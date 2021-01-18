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
            .withTitleColor(Colors.Text.primary)
            .withAlignment(.right)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Component.separator
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
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
    func bind(_ viewModel: AssetViewModel) {
        if let assetDetail = viewModel.assetDetail {
            assetNameView.setAssetName(for: assetDetail)
        }
        actionButton.setTitle(viewModel.amount, for: .normal)
    }

    func bind(_ viewModel: AssetAdditionViewModel) {
        actionButton.backgroundColor = viewModel.backgroundColor
        if let assetDetail = viewModel.assetDetail {
            assetNameView.setAssetName(for: assetDetail)
        }
        actionButton.setTitleColor(viewModel.actionColor, for: .normal)
        actionButton.setTitle(viewModel.id, for: .normal)
    }

    func bind(_ viewModel: AssetRemovalViewModel) {
        if let assetDetail = viewModel.assetDetail {
            assetNameView.setAssetName(for: assetDetail)
        }
        actionButton.titleLabel?.font = viewModel.actionFont
        actionButton.setTitleColor(viewModel.actionColor, for: .normal)
        actionButton.setTitle(viewModel.actionText, for: .normal)
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
            make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-layout.current.assetNameOffet)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
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
    func setEnabled(_ isEnabled: Bool) {
        backgroundColor = isEnabled ? Colors.Background.secondary : Colors.Background.disabled
    }
    
    func setSeparatorViewHidden(_ isHidden: Bool) {
        separatorView.isHidden = isHidden
    }
}

extension AssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let assetNameOffet: CGFloat = 10.0
        let separatorHeight: CGFloat = 1.0
        let verticalInset: CGFloat = 16.0
        let separatorInset: CGFloat = 10.0
    }
}

protocol AssetViewDelegate: class {
    func assetViewDidTapActionButton(_ assetView: AssetView)
}
