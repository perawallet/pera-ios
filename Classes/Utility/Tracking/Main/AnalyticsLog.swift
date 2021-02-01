//
//  AnalyticsLog.swift

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
