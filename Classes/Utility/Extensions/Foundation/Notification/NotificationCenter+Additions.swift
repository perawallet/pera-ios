//
//  NotificationCenter+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension NotificationCenter {
    
    static func unobserve(_ tracker: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(tracker)
    }
}
