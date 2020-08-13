//
//  LedgerTroubleshootOption.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct LedgerTroubleshootOption {
    let number: Options
    let option: String
}

extension LedgerTroubleshootOption {
    enum Options: Int {
        case closeOthers = 1
        case restart = 2
        case appSupport = 3
        case ledgerSupport = 4
    }
}
