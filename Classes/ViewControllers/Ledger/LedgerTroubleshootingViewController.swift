//
//  LedgerTroubleshootingViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootingViewController: BaseScrollViewController {
    
    private lazy var ledgerTutorialInstructionListView = LedgerTutorialInstructionListView()
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-troubleshooting-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        ledgerTutorialInstructionListView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerTroubleshootingViewLayout()
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension LedgerTroubleshootingViewController {
    private func setupLedgerTroubleshootingViewLayout() {
        contentView.addSubview(ledgerTutorialInstructionListView)
        
        ledgerTutorialInstructionListView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

// MARK: LedgerTutorialInstructionListViewDelegate
extension LedgerTroubleshootingViewController: LedgerTutorialInstructionListViewDelegate {
    func ledgerTutorialInstructionListViewDidTapOpenApp(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootOpenApp, by: .present)
    }
    
    func ledgerTutorialInstructionListViewDidTapInstallApp(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootInstallApp, by: .present)
    }
    
    func ledgerTutorialInstructionListViewDidTapBluetoothConnection(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootBluetooth, by: .present)
    }
    
    func ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(_ view: LedgerTutorialInstructionListView) {
        open(.ledgerTroubleshootLedgerConnection, by: .present)
    }
}
