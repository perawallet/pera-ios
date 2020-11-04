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
    var name: String { get }
    var params: [String: String] { get }
    func record()
}

extension ErrorLog {
    func record() {
        var mutableParams = params
        mutableParams["os"] = "ios"
        mutableParams["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let error = NSError(domain: name, code: id, userInfo: mutableParams)
        Crashlytics.crashlytics().record(error: error)
    }
}
