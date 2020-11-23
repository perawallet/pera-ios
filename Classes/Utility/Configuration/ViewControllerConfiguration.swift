//
//  ViewControllerConfiguration.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

class ViewControllerConfiguration {
    let api: AlgorandAPI?
    var session: Session?
    
    init(api: AlgorandAPI?, session: Session?) {
        self.api = api
        self.session = session
    }
}
