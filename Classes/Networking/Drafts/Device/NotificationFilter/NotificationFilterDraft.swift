//
//  NotificationFilterDraft.swift

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
