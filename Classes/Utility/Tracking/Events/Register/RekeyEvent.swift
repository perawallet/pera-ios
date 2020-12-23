//
//  RekeyEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct RekeyEvent: AnalyticsEvent {
    let key: AnalyticsEventKey = .rekey
}
