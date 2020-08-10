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
    
    private let connectedDeviceId: UUID
    private let connectedDeviceName: String?
    
    init(connectedDeviceId: UUID, connectedDeviceName: String?, configuration: ViewControllerConfiguration) {
        self.connectedDeviceId = connectedDeviceId
        self.connectedDeviceName = connectedDeviceName
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = ""
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
