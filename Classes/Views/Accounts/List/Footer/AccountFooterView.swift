//
//  AssetFooterView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountFooterViewDelegate: class {
    func accountFooterViewDidTapAddAssetButton(_ accountFooterView: AccountFooterView)
}

class AccountFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountFooterViewDelegate?
    
    private lazy var addAssetButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 5.0, y: 0.0), title: CGPoint(x: -5.0, y: 0.0))
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-plus-purple"), for: .normal)
        button.setBackgroundImage(img("bg-purple-bordered"), for: .normal)
        button.setTitle("asset-title".localized, for: .normal)
        button.setTitleColor(SharedColors.purple, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .bold(size: 13.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override func prepareLayout() {
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
    private func setupAddAssetButtonLayout() {
        addSubview(addAssetButton)
        
        addAssetButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.bottom.equalToSuperview()
        }
    }
}

extension AccountFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 5.0
        let horizontalInset: CGFloat = 10.0
    }
}
