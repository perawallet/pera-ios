//
//  AccountsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var headerView = AssetDetailHeaderView()
    
    weak var delegate: AssetDetailViewDelegate?
    
    override func linkInteractors() {
        headerView.delegate = self
    }
    
    override func prepareLayout() {
        setupHeaderViewLayout()
    }
}

extension AssetDetailView {
    private func setupHeaderViewLayout() {
        addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension AssetDetailView: AssetDetailHeaderViewDelegate {
    func assetDetailHeaderViewDidTapSendButton(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapSendButton(self)
    }
    
    func assetDetailHeaderViewDidTapReceiveButton(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapReceiveButton(self)
    }
    
    func assetDetailHeaderView(
        _ assetDetailHeaderView: AssetDetailHeaderView,
        didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer
    ) {
        delegate?.assetDetailView(self, didTrigger: dollarValueGestureRecognizer)
    }
    
    func assetDetailHeaderView(
        _ assetDetailHeaderView: AssetDetailHeaderView,
        didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer
    ) {
        delegate?.assetDetailView(self, didTriggerAssetIdCopyValue: gestureRecognizer)
    }
    
    func assetDetailHeaderViewDidTapRewardView(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidTapRewardView(self)
    }
}

extension AssetDetailView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 32.0
        static var algosHeaderHeight: CGFloat = 260.0
        static var assetHeaderHeight: CGFloat = 212.0
    }
}

protocol AssetDetailViewDelegate: class {
    func assetDetailViewDidTapSendButton(_ assetDetailView: AssetDetailView)
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView)
    func assetDetailView(_ assetDetailView: AssetDetailView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer)
    func assetDetailView(_ assetDetailView: AssetDetailView, didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer)
    func assetDetailViewDidTapRewardView(_ assetDetailView: AssetDetailView)
}
