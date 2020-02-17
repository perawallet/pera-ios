//
//  AppConfiguration.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class AppConfiguration {

    let api: API
    let session: Session
    let transactionController: TransactionController
    
    init(api: API, session: Session) {
        self.api = api
        self.session = session
        self.transactionController = TransactionController(api: api)
    }
    
    func all() -> ViewControllerConfiguration {
        let configuration = ViewControllerConfiguration(api: api, session: session)
        configuration.transactionController = transactionController
        return configuration
    }
    
    func clearAll() {
        self.session.clear(.keychain)
        self.session.clear(.defaults)
    }
}
