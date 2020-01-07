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
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 12.0)))
            .withTitleColor(SharedColors.purple)
            .withAlignment(.right)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupAssetNameViewLayout()
        setupActionButtonLayout()
    }
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
}

extension AssetActionableView {
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.assetActionableViewDidTapActionButton(self)
    }
}

extension AssetActionableView {
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.leftInset)
        }
    }

    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.rightInset)
        }
    }
}

extension AssetActionableView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let leftInset: CGFloat = 15.0
        let rightInset: CGFloat = 17.0
    }
}
