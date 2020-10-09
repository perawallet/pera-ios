//
//  SwiftDate+Region.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import SwiftDate

extension SwiftDate {
    static func setupDateRegion() {
        SwiftDate.defaultRegion = Region(
            calendar: Calendar.autoupdatingCurrent,
            zone: TimeZone.autoupdatingCurrent,
            locale: Locales.autoUpdating
        )
    }
}
