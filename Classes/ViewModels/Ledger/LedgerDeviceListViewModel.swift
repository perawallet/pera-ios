//
//  LedgerDeviceListViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerDeviceListViewModel {
    func configure(_ cell: LedgerDeviceCell, with ledgerName: String) {
        cell.contextView.setDeviceName(ledgerName)
    }
}
