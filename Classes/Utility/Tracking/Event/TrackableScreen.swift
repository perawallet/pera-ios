//
//  TrackableScreen.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Firebase

protocol TrackableScreen {
    var screenKey: String? { get }
    func trackScreen()
}

extension TrackableScreen {
    func trackScreen() {
        if let screen = screenKey {
            Analytics.logEvent(screen, parameters: nil)
        }
    }
}
