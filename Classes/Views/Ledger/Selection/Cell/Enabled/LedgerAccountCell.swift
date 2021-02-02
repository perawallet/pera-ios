//
//  LedgerAccountCell.swift

import UIKit

class LedgerAccountCell: BaseCollectionViewCell<LedgerAccountView> {
    
    weak var delegate: LedgerAccountCellDelegate?
    
    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.clear()
    }
}

extension LedgerAccountCell {
    func bind(_ viewModel: LedgerAccountSelectionViewModel) {
        contextView.bind(viewModel)
    }
    
    func bind(_ viewModel: LedgerAccountNameViewModel) {
        contextView.bind(viewModel)
    }
}

extension LedgerAccountCell: LedgerAccountViewDelegate {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountView) {
        delegate?.ledgerAccountCellDidOpenMoreInfo(self)
    }
}

protocol LedgerAccountCellDelegate: class {
    func ledgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: LedgerAccountCell)
}
