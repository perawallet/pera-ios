//
//  ActiveAuctionCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ActiveAuctionCellDelegate: class {
    
    func activeAuctionCellDidTapEnterAuctionButton(_ activeAuctionCell: ActiveAuctionCell)
}

class ActiveAuctionCell: BaseCollectionViewCell<ActiveAuctionView> {
    
    weak var delegate: ActiveAuctionCellDelegate?
    
    override func linkInteractors() {
        super.linkInteractors()
        
        contextView.delegate = self
    }
}

extension ActiveAuctionCell: ActiveAuctionViewDelegate {
    
    func activeAuctionViewDidTapEnterAuctionButton(_ activeAuctionView: ActiveAuctionView) {
        delegate?.activeAuctionCellDidTapEnterAuctionButton(self)
    }
}
