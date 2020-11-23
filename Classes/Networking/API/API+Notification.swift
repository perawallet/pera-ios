//
//  API+Notification.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension AlgorandAPI {
    @discardableResult
    func registerDevice(
        with draft: DeviceRegistrationDraft,
        then handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/")
            .method(.post)
            .headers(mobileApiHeaders())
            .body(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func updateDevice(
        with draft: DeviceUpdateDraft,
        then handler: @escaping (Response.Result<Device, HIPAPIError>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/\(draft.id)")
            .method(.put)
            .headers(mobileApiHeaders())
            .body(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func unregisterDevice(with draft: DeviceDeletionDraft) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/")
            .method(.delete)
            .headers(mobileApiHeaders())
            .body(draft)
            .build()
            .send()
    }
    
    @discardableResult
    func getNotifications(
        for id: String,
        with cursorQuery: CursorQuery,
        then handler: @escaping (Response.ModelResult<PaginatedList<NotificationMessage>>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/devices/\(id)/notifications/")
            .headers(mobileApiHeaders())
            .query(cursorQuery)
            .completionHandler(handler)
            .build()
            .send()
    }
}
