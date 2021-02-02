//
//  DeviceDeletionDraft.swift

import Magpie

struct DeviceDeletionDraft: JSONObjectBody {
    let pushToken: String
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.pushToken, pushToken))
        return params
    }
}
