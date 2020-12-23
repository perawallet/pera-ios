//
//  AnalyticsLog.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

protocol AnalyticsLog {
    var id: Int { get }
    var name: AnalyticsLogName { get }
    var params: AnalyticsParameters { get }
}

extension AnalyticsLog {
    var id: Int {
        return AnalyticsLogName.allCases.firstIndex(of: name) ?? -1
    }
}

enum AnalyticsLogName: String, CaseIterable {
    case ledgerTransactionError = "LedgerTransactionError"
}
