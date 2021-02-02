//
//  AlgosCardCell.swift

import UIKit

class AlgosCardCell: BaseCollectionViewCell<AlgosCardView> {
    
    weak var delegate: AlgosCardCellDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }
}

extension AlgosCardCell: AlgosCardViewDelegate {
    func algosCardViewDidOpenRewardDetails(_ algosCardView: AlgosCardView) {
        delegate?.algosCardCellDidOpenRewardDetails(self)
    }
}

protocol AlgosCardCellDelegate: class {
    func algosCardCellDidOpenRewardDetails(_ algosCardCell: AlgosCardCell)
}
