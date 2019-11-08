//
//  LimitOrderCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol LimitOrderCellDelegate: class {
    
    func limitOrderCellDidTapRetractButton(_ limitOrderCell: LimitOrderCell)
}

class LimitOrderCell: BaseCollectionViewCell<LimitOrderCellContextView> {
    
    weak var delegate: LimitOrderCellDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        contextView.delegate = self
    }
}

// MARK: LimitOrderCellContextViewDelegate

extension LimitOrderCell: LimitOrderCellContextViewDelegate {
    
    func limitOrderCellContextViewDidTapRetractButton(_ limitOrderCellContextView: LimitOrderCellContextView) {
        delegate?.limitOrderCellDidTapRetractButton(self)
    }
}
