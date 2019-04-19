//
//  API.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class API: Magpie<AlamofireNetworking> {
    
    typealias APICompletionHandler<ObjectRef> = (Response<ObjectRef>) -> Void where ObjectRef: Mappable
    
    override var commonHttpHeaders: HTTPHeaders {
        
        var httpHeaders = super.commonHttpHeaders
        
        guard let token = self.token else {
            return httpHeaders
        }
        
        httpHeaders.append(.custom(header: "X-Algo-API-Token", value: token))
        
        return httpHeaders
    }
    
    var token: String?
    
    private(set) var session: Session?
    
    required init(base: String, session: Session?) {
        super.init(base: base)
        
        self.session = session
    }
    
    @available(*, unavailable)
    required init(base: String, networking: AlamofireNetworking) {
        fatalError("init(base:networking:) has not been implemented")
    }
}
