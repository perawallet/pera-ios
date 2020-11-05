//
//  ErrorLog.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Firebase

protocol ErrorLog {
    var id: Int { get }
    var name: ErrorLogs { get }
    var params: [ErrorLogParamKeys: Any] { get }
    func record()
}

extension ErrorLog {
    var id: Int {
        return ErrorLogs.allCases.firstIndex(of: name) ?? -1
    }
    
    func record() {
        var mutableParams = params
        mutableParams[.os] = "ios"
        mutableParams[.version] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let error = NSError(domain: name.rawValue, code: id, userInfo: mutableParams.transformToAnalyticsFormat())
        Crashlytics.crashlytics().record(error: error)
    }
}

enum ErrorLogs: String, CaseIterable {
    case ledgerTransactionError = "LedgerTransactionError"
}

enum ErrorLogParamKeys: String {
    case os = "os"
    case version = "version"
    case sender = "sender"
    case unsignedTransaction = "unsigned_transaction"
    case signedTransaction = "signed_transaction"
}
