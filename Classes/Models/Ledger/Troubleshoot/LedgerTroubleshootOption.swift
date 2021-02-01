//
//  LedgerTroubleshootOption.swift

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
