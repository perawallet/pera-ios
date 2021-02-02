//
//  SwiftDate+Region.swift

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
