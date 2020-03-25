//
//  LedgerTutorialViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTutorialViewController: BaseScrollViewController {
    
    private lazy var ledgerTutorialView = LedgerTutorialView()
    
    private let mode: AccountSetupMode
    
    init(mode: AccountSetupMode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let infoButtonItem = ALGBarButtonItem(kind: .infoBordered) { [weak self] in
            
        }
        rightBarButtonItems = [infoButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-pair-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTutorialView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerTutorialViewLayout()
    }
}

extension LedgerTutorialViewController {
    private func setupLedgerTutorialViewLayout() {
        contentView.addSubview(ledgerTutorialView)
        
        ledgerTutorialView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTutorialViewController: LedgerTutorialViewDelegate {
    func ledgerTutorialViewDidTapSearchButton(_ ledgerTutorialView: LedgerTutorialView) {
        open(.ledgerDeviceList(mode: mode), by: .push)
    }
    
    func ledgerTutorialView(_ ledgerTutorialView: LedgerTutorialView, didTap section: LedgerTutorialSection) {
        switch section {
        case .ledgerBluetoothConnection:
            open(.ledgerTroubleshootBluetooth, by: .present)
        case .bluetoothConnection:
            open(.ledgerTroubleshootBluetooth, by: .present)
            
        default:
            return
        }
    }
}
