//
//  TransactionAssetView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var assetNameView = AssetNameView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        titleLabel.text = "asset-title".localized
        assetNameView.removeId()
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAssetNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionAssetView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumOffset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension TransactionAssetView {
    func setAssetName(for assetDetail: AssetDetail) {
        assetNameView.setAssetName(for: assetDetail)
    }
    
    func setAssetVerified(_ hidden: Bool) {
        assetNameView.setVerified(hidden)
    }
    
    func setAssetName(_ name: String) {
        assetNameView.setName(name)
    }
    
    func setAssetCode(_ code: String) {
        assetNameView.setCode(code)
    }
    
    func setAssetId(_ id: String) {
        assetNameView.setId(id)
    }
    
    func removeAssetId() {
        assetNameView.removeId()
    }
}

extension TransactionAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let minimumOffset: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
    }
}
