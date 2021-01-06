//
//  NotificationFilterDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Magpie

struct NotificationFilterDraft: JSONObjectBody {
    let deviceId: String
    let accountAddress: String
    let receivesNotifications: Bool

    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.receivesNotifications, receivesNotifications))
        return params
    }
}
