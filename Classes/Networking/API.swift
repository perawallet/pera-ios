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
    
}
