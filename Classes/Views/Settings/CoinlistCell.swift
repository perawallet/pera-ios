//
//  CoinlistCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol CoinlistCellDelegate: class {
    
    func coinlistCellDidTapActionButton(_ coinlistCell: CoinlistCell)
}

class CoinlistCell: BaseCollectionViewCell<CoinlistCellContextView> {
    
    weak var delegate: CoinlistCellDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }
}

extension CoinlistCell: CoinlistCellContextViewDelegate {
    
    func coinlistCellContextViewDidTapActionButton(_ coinlistCellContextView: CoinlistCellContextView) {
        delegate?.coinlistCellDidTapActionButton(self)
    }
}
