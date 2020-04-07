//
//  LedgerDeviceCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class LedgerDeviceCell: BaseCollectionViewCell<LedgerDeviceView> {
    
    weak var delegate: LedgerDeviceCellDelegate?
    
    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
}

extension LedgerDeviceCell: LedgerDeviceViewDelegate {
    func ledgerDeviceViewDidTapConnectButton(_ ledgerDeviceView: LedgerDeviceView) {
        delegate?.ledgerDeviceCellDidTapConnectButton(self)
    }
}

protocol LedgerDeviceCellDelegate: class {
    func ledgerDeviceCellDidTapConnectButton(_ ledgerDeviceCell: LedgerDeviceCell)
}
