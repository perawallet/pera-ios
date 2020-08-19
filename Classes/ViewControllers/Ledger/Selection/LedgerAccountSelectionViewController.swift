//
//  LedgerAccountSelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionViewController: BaseViewController {
    
    private lazy var ledgerAccountSelectionView = LedgerAccountSelectionView()
    
    private let ledger: LedgerDetail
    
    init(ledger: LedgerDetail, configuration: ViewControllerConfiguration) {
        self.ledger = ledger
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = ledger.name
    }
    
    override func prepareLayout() {
        setupLedgerAccountSelectionViewLayout()
    }
}

extension LedgerAccountSelectionViewController {
    private func setupLedgerAccountSelectionViewLayout() {
        view.addSubview(ledgerAccountSelectionView)
        
        ledgerAccountSelectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerAccountSelectionViewController: LedgerAccountSelectionViewDelegate {
    func ledgerAccountSelectionViewDidAddAccount(_ ledgerAccountSelectionView: LedgerAccountSelectionView) {
        
    }
}
