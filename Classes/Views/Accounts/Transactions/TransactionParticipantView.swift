//
//  TransactionParticipantView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionParticipantView: BaseView {
    
    private(set) lazy var accountSelectionView = SelectionView(hasLeftImageView: true)
    
    private(set) lazy var assetSelectionView: SelectionView = {
        let assetSelectionView = SelectionView()
        assetSelectionView.leftExplanationLabel.text = "history-asset".localized
        return assetSelectionView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        assetSelectionView.set(enabled: false)
    }
    
    override func prepareLayout() {
        setupAccountSelectionViewLayout()
        setupAssetSelectionViewLayout()
    }
}

extension TransactionParticipantView {
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAssetSelectionViewLayout() {
        addSubview(assetSelectionView)
        
        assetSelectionView.snp.makeConstraints { make in
            make.top.equalTo(accountSelectionView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
