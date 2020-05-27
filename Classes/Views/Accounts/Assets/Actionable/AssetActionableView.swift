//
//  AssetActionableView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AssetActionableViewDelegate: class {
    func assetActionableViewDidTapActionButton(_ assetActionableView: AssetActionableView)
}

class AssetActionableView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetActionableViewDelegate?
    
    private(set) lazy var assetNameView = AssetNameView()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
            .withTitleColor(SharedColors.red)
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

extension AssetActionableView {
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.assetActionableViewDidTapActionButton(self)
    }
}

extension AssetActionableView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(layout.current.assetNameOffset)
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

extension AssetActionableView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let assetNameOffset: CGFloat = 10.0
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 10.0
    }
}
