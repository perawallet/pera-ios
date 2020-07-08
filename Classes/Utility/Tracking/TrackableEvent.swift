//
//  TrackableEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Firebase

protocol TrackableEvent {
    var eventKey: String { get }
    var parameters: [String: Any]? { get }
    func logEvent()
}

extension TrackableEvent {
    func logEvent() {
        Analytics.logEvent(eventKey, parameters: parameters)
    }
}
