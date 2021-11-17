// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public struct Duration {
    public static let secondsInOneMinute = 60
    public static let minutesInOneHour = 60
    public static let hoursInOneDay = 24
    public static let daysInOneWeek = 7

    public let seconds: Int

    public init(minutes: Int) {
        self.seconds = minutes * Self.secondsInOneMinute
    }
}

extension Duration {
    public func calculateApproximateDateInterval() -> DateInterval {
        let secondsInOneWeek = Self.secondsInOneMinute * Self.minutesInOneHour * Self.hoursInOneDay * Self.daysInOneWeek
        let numberOfWeeks = Double(seconds) / Double(secondsInOneWeek)
        if numberOfWeeks >= 1 {
            return .init(n: Int(numberOfWeeks.rounded()), unit: .week)
        }
        let secondsInOneDay = Self.secondsInOneMinute * Self.minutesInOneHour * Self.hoursInOneDay
        let numberOfDays = Double(seconds) / Double(secondsInOneDay)
        if numberOfDays > 6 {
            return .init(n: 1, unit: .week)
        }
        if numberOfDays >= 1 {
            return .init(n: Int(numberOfDays.rounded()), unit: .day)
        }
        let secondsInHours = Self.secondsInOneMinute * Self.minutesInOneHour
        let numberOfHours = Double(seconds) / Double(secondsInHours)
        if numberOfHours > 23 {
            return .init(n: 1, unit: .day)
        }
        if numberOfHours >= 1 {
            return .init(n: Int(numberOfHours.rounded()), unit: .hour)
        }
        let numberOfMinutes = Double(seconds) / Double(Self.secondsInOneMinute)
        if numberOfMinutes > 59 {
            return .init(n: 1, unit: .hour)
        }
        if numberOfMinutes >= 1 {
            return .init(n: Int(numberOfMinutes.rounded()), unit: .minute)
        }
        return .init(n: seconds, unit: .second)
    }
}

extension Duration {
    public struct DateInterval {
        public let n: Int
        public let unit: Unit
    }

    public enum Unit {
        case week
        case day
        case hour
        case minute
        case second
    }
}
