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
        httpHeaders.append(.custom(header: "X-Algo-API-Token", value: "af1cf81622d34a9e25c11277b9a591525f0a66611850050f5102030598cce8d7"))
        
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
