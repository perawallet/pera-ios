//
//  AssetHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountHeaderViewDelegate: class {
    func accountHeaderViewDidTapOptionsButton(_ accountHeaderView: AccountHeaderView)
}

class AccountHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountHeaderViewDelegate?
    
    private lazy var imageView = UIImageView(image: img("icon-logo-small"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
    }()
    
    private lazy var optionsButton: UIButton = {
        UIButton(type: .custom)
    }()
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupOptionsButtonLayout()
        setupTitleLabelLayout()
    }
    
    override func setListeners() {
        optionsButton.addTarget(self, action: #selector(notifyDelegateToOptionsButtonTapped), for: .touchUpInside)
    }
}

extension AccountHeaderView {
    @objc
    private func notifyDelegateToOptionsButtonTapped() {
        delegate?.accountHeaderViewDidTapOptionsButton(self)
    }
}

extension AccountHeaderView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupOptionsButtonLayout() {
        addSubview(optionsButton)
        
        optionsButton.snp.makeConstraints { _ in
            
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { _ in
            
        }
    }
}

extension AccountHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        
    }
}
