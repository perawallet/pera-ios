//
//  RekeyConfirmationFooterSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RekeyConfirmationFooterSupplementaryView: BaseSupplementaryView<RekeyConfirmationFooterView> {
    
    weak var delegate: RekeyConfirmationFooterSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension RekeyConfirmationFooterSupplementaryView: RekeyConfirmationFooterViewDelegate {
    func rekeyConfirmationFooterViewDidShowMoreAssets(_ rekeyConfirmationFooterView: RekeyConfirmationFooterView) {
        delegate?.rekeyConfirmationFooterSupplementaryViewDidShowMoreAssets(self)
    }
}

protocol RekeyConfirmationFooterSupplementaryViewDelegate: class {
    func rekeyConfirmationFooterSupplementaryViewDidShowMoreAssets(
        _ rekeyConfirmationFooterSupplementaryView: RekeyConfirmationFooterSupplementaryView
    )
}
