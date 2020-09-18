//
//  API+Notification.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func registerDevice(
        with draft: DeviceRegistrationDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<Device>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/devices/"))
            .base(mobileApiBase)
            .httpMethod(.post)
            .httpHeaders(mobileApiHeaders())
            .httpBody(draft)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func updateDevice(
        with draft: DeviceUpdateDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<Device>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/devices/\(draft.id)"))
            .base(mobileApiBase)
            .httpMethod(.put)
            .httpHeaders(mobileApiHeaders())
            .httpBody(draft)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func unregisterDevice(with draft: DeviceDeletionDraft) -> EndpointOperatable {
        return Endpoint(path: Path("/api/devices/"))
            .base(mobileApiBase)
            .httpHeaders(mobileApiHeaders())
            .httpMethod(.delete)
            .httpBody(draft)
            .buildAndSend(self)
    }
    
    @discardableResult
    func getNotifications(
        for id: String,
        with cursorQuery: CursorQuery,
        then handler: @escaping Endpoint.DefaultResultHandler<PaginatedList<NotificationMessage>>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/devices/\(id)/notifications/"))
            .base(mobileApiBase)
            .httpHeaders(mobileApiHeaders())
            .query(cursorQuery)
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
