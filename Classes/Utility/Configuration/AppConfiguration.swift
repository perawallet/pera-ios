//
//  AppConfiguration.swift

import Foundation

class AppConfiguration {

    let api: AlgorandAPI
    let session: Session
    
    init(api: AlgorandAPI, session: Session) {
        self.api = api
        self.session = session
    }
    
    func all() -> ViewControllerConfiguration {
        let configuration = ViewControllerConfiguration(api: api, session: session)
        return configuration
    }
    
    func clearAll() {
        self.session.clear(.keychain)
        self.session.clear(.defaults)
    }
}
