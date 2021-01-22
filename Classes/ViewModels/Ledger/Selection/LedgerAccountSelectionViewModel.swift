//
//  LedgerAccountSelectionViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionViewModel {
    
    private(set) var subviews: [UIView] = []
    
    private let isMultiSelect: Bool
    let isSelected: Bool
    
    init(account: Account, isMultiSelect: Bool, isSelected: Bool) {
        self.isMultiSelect = isMultiSelect
        self.isSelected = isSelected
        setSubviews(from: account)
    }
    
    private func setSubviews(from account: Account) {
        addLedgerAccountNameView(with: account)
        addAlgoView(with: account)
        addLedgerAssetCountViewIfNeeded(with: account)
    }
    
    private func addLedgerAccountNameView(with account: Account) {
        let ledgerAccountNameView = LedgerAccountNameView()
        ledgerAccountNameView.bind(LedgerAccountNameViewModel(account: account, isMultiSelect: isMultiSelect, isSelected: isSelected))
        subviews.append(ledgerAccountNameView)
    }
    
    private func addAlgoView(with account: Account) {
        let algoView = AlgoAssetView()
        setAlgoAmount(from: account, in: algoView)
        
        if account.assets.isNilOrEmpty {
            algoView.setSeparatorHidden(true)
        }
        
        subviews.append(algoView)
    }
    
    private func addLedgerAssetCountViewIfNeeded(with account: Account) {
        if !account.assets.isNilOrEmpty {
            let ledgerAssetCountView = LedgerAccountAssetCountView()
            ledgerAssetCountView.bind(LedgerAccountAssetCountViewModel(account: account))
            subviews.append(ledgerAssetCountView)
            return
        }
    }
    
    private func setAlgoAmount(from account: Account, in view: AlgoAssetView) {
        view.bind(AlgoAssetViewModel(account: account))
    }
}
