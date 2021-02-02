//
//  LedgerDeviceCell.swift

import Foundation

class LedgerDeviceCell: BaseCollectionViewCell<LedgerDeviceView> {
    
    weak var delegate: LedgerDeviceCellDelegate?
    
    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }

    func bind(_ viewModel: LedgerDeviceListViewModel) {
        contextView.bind(viewModel)
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
