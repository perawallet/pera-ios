//
//  DeviceDeletionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

struct DeviceDeletionDraft: JSONObjectBody {
    let pushToken: String
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.pushToken, pushToken))
        return params
    }
}
