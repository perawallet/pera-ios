//
//  AccountsHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsHeaderViewDelegate: class {
    
    func accountsHeaderViewDidTapSendButton(_ accountsHeaderView: AccountsHeaderView)
    func accountsHeaderViewDidTapReceiveButton(_ accountsHeaderView: AccountsHeaderView)
}

class AccountsHeaderView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
    }
    
    // MARK: Components
    
    // algos available label
    
    // amount label
    
    // send button
    
    // receive button
    
    // history label
    
    weak var delegate: AccountsHeaderViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAmountLabelLayout()
        setupSendButtonLayout()
        setupReceiveButtonLayout()
        setupHistoryLabelLayout()
    }
    
    private func setupTitleLabelLayout() {
        
    }
    
    private func setupAmountLabelLayout() {
        
    }
    
    private func setupSendButtonLayout() {
        
    }
    
    private func setupReceiveButtonLayout() {
        
    }
    
    private func setupHistoryLabelLayout() {
        
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        
    }
    
    @objc
    private func notifyDelegateToReceiveButtonTapped() {
        
    }
}
