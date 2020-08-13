//
//  LedgerAccountSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerAccountSelectionViewDelegate?
    
    private lazy var addButton = MainButton(title: "ledger-account-selection-add".localized)
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAddButtonLayout()
        setupAccountSelectionListViewLayout()
    }
}

extension LedgerAccountSelectionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.ledgerAccountSelectionViewDidAddAccount(self)
    }
}

extension LedgerAccountSelectionView {
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
    
    private func setupAccountSelectionListViewLayout() {
        
    }
}

extension LedgerAccountSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol LedgerAccountSelectionViewDelegate: class {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView)
}
