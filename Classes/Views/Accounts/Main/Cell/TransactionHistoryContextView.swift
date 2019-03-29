//
//  TransactionHistoryContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
    }
    
    // MARK: Components
    
    // transaction detail label
    
    // amount label
    
    // date label
    
    // account name label
    
    // separator view
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTransactionDetailLabelLayout()
        setupAmountLabelLayout()
        setupDateLabelLayout()
        setupAccountNameLabelLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupTransactionDetailLabelLayout() {
        
    }
    
    private func setupAmountLabelLayout() {
        
    }
    
    private func setupDateLabelLayout() {
        
    }
    
    private func setupAccountNameLabelLayout() {
        
    }
    
    private func setupSeparatorViewLayout() {
        
    }
}
