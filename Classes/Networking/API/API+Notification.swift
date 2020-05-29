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
    func registerDevice(with draft: DeviceRegistrationDraft, then handler: BoolHandler? = nil) -> EndpointOperatable {
        let resultHandler: Endpoint.RawResultHandler = { result in
            switch result {
            case .success:
                handler?(true)
            case .failure:
                handler?(false)
            }
        }
        
        return Endpoint(path: Path("/api/devices/"))
            .base(mobileApiBase)
            .httpMethod(.post)
            .httpHeaders(mobileApiHeaders())
            .httpBody(draft)
            .resultHandler(resultHandler)
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
}
