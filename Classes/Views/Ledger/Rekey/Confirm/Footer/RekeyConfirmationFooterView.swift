//
//  RekeyConfirmationFooterView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RekeyConfirmationFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RekeyConfirmationFooterViewDelegate?
    
    private lazy var showMoreButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(Colors.Text.secondary)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupShowMoreButtonLayout()
    }
    
    override func setListeners() {
        showMoreButton.addTarget(self, action: #selector(notifyDelegateToShowMoreAssets), for: .touchUpInside)
    }
}

extension RekeyConfirmationFooterView {
    @objc
    private func notifyDelegateToShowMoreAssets() {
        delegate?.rekeyConfirmationFooterViewDidShowMoreAssets(self)
    }
}

extension RekeyConfirmationFooterView {
    private func setupShowMoreButtonLayout() {
        addSubview(showMoreButton)
        
        showMoreButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension RekeyConfirmationFooterView {
    func setMoreAssetsButtonTitle(_ title: String?) {
        showMoreButton.setTitle(title, for: .normal)
    }
}

extension RekeyConfirmationFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 4.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol RekeyConfirmationFooterViewDelegate: class {
    func rekeyConfirmationFooterViewDidShowMoreAssets(_ rekeyConfirmationFooterView: RekeyConfirmationFooterView)
}
