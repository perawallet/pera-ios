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
    func registerDevice(with draft: DeviceRegistrationDraft) -> EndpointOperatable {
        return Endpoint(path: Path("/api/devices/"))
            .base(Environment.current.mobileApi)
            .httpMethod(.post)
            .httpBody(draft)
            .buildAndSend(self)
    }
    
    @discardableResult
    func unregisterDevice(with draft: DeviceDeletionDraft) -> EndpointOperatable {
        return Endpoint(path: Path("/api/devices/"))
            .base(Environment.current.mobileApi)
            .httpMethod(.delete)
            .httpBody(draft)
            .buildAndSend(self)
    }
}
