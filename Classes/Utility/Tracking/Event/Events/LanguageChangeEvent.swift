//
//  LanguageChangeEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 7.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct LanguageChangeEvent: TrackableEvent {
    let eventKey = "language_change"
    
    let languageId: String
    
    var parameters: [String: Any]? {
        return [
            "id": languageId
        ]
    }
}
