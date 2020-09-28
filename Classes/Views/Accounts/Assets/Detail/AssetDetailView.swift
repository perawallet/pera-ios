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
    func assetDetailHeaderViewDidCopyAssetId(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidCopyAssetId(self)
    }
    
    func assetDetailHeaderViewDidOpenRewardDetails(_ assetDetailHeaderView: AssetDetailHeaderView) {
        delegate?.assetDetailViewDidOpenRewardDetails(self)
    }
}

extension AssetDetailView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 32.0
        static var algosHeaderHeight: CGFloat = 230.0
        static var assetHeaderHeight: CGFloat = 180.0
    }
}

protocol AssetDetailViewDelegate: class {
    func assetDetailViewDidCopyAssetId(_ assetDetailView: AssetDetailView)
    func assetDetailViewDidOpenRewardDetails(_ assetDetailView: AssetDetailView)
}
