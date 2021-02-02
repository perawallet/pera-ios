//
//  ViewControllerConfiguration.swift

import Foundation

class ViewControllerConfiguration {
    let api: AlgorandAPI?
    var session: Session?
    
    init(api: AlgorandAPI?, session: Session?) {
        self.api = api
        self.session = session
    }
}
