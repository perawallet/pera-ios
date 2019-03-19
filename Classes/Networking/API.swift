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
    
    override var commonHttpHeaders: HTTPHeaders {
        
        var httpHeaders = super.commonHttpHeaders
        httpHeaders.append(.custom(header: "X-Algo-API-Token", value: "0341e47be703d3e305c8f6789f62b3c56b69c5b3cfca5f9da1b3b53fb3181d25"))
        
        return httpHeaders
    }
    
    private var session: Session?
    
    required init(base: String, session: Session?) {
        super.init(base: base)
        
        self.session = session
    }
    
    @available(*, unavailable)
    required init(base: String, networking: AlamofireNetworking) {
        fatalError("init(base:networking:) has not been implemented")
    }
}
