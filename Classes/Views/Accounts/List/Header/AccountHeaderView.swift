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
    
    private lazy var imageView = UIImageView(image: img("icon-account-purple"))
    
    private lazy var titleLabel: UILabel = {
        UILabel().withAlignment(.left).withFont(UIFont.font(.avenir, withWeight: .bold(size: 11.0)))
    }()
    
    private lazy var optionsButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-options"))
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
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupOptionsButtonLayout() {
        addSubview(optionsButton)
        
        optionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelInset)
            make.centerY.equalTo(imageView)
            make.trailing.equalTo(optionsButton.snp.leading).offset(-layout.current.labelInset)
        }
    }
}

extension AccountHeaderView {
    func setAccountName(_ name: String) {
        titleLabel.attributedText = name.attributed([.letterSpacing(1.10), .textColor(SharedColors.black)])
    }
    
    func setOptionsButton(hidden: Bool) {
        optionsButton.isHidden = hidden
    }
}

extension AccountHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 8.0
        let labelInset: CGFloat = 10.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let verticalInset: CGFloat = 17.0
    }
}
