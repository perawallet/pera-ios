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
    
    private lazy var addAssetButton: UIButton = {
        UIButton(type: .custom)
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
        
        addAssetButton.snp.makeConstraints { _ in
            
        }
    }
}

extension AccountFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
}
