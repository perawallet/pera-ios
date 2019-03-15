//
//  API.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class API: Magpie<AlamofireNetworking> {
    
    typealias CompletionHandler<ObjectRef> = (Response<ObjectRef>) -> Void where ObjectRef: Mappable
    
    private var session: Session?
    
    required init(base: String, session: Session?) {
        super.init(base: base)
        
        self.session = session
    }
    
    required init(base: String, networking: AlamofireNetworking) {
        fatalError("init(base:networking:) has not been implemented")
    }
}
