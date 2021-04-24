// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AlgosUSDValueInterval.swift

import Foundation

enum AlgosUSDValueInterval {
    case hourly
    case daily
    case weekly
    case monthly
    case yearly
    case all

    func getIntervalRange() -> (since: TimeInterval, until: TimeInterval) {
        let currentDate = Date()

        switch self {
        case .hourly:
            return (since: TimeIntervalConstants.lastHour, until: currentDate.timeIntervalSince1970)
        case .daily:
            return (since: TimeIntervalConstants.yesterday, until: currentDate.timeIntervalSince1970)
        case .weekly:
            return (since: TimeIntervalConstants.lastWeek, until: currentDate.timeIntervalSince1970)
        case .monthly:
            return (since: TimeIntervalConstants.lastMonth, until: currentDate.timeIntervalSince1970)
        case .yearly:
            return (since: TimeIntervalConstants.lastYear, until: currentDate.timeIntervalSince1970)
        case .all:
            return (since: 0, until: currentDate.timeIntervalSince1970)
        }
    }

    func getIntervalRepresentation() -> String {
        switch self {
        case .hourly:
            return "1H"
        case .daily:
            return "1D"
        case .weekly:
            return "7D"
        case .monthly:
            return "30D"
        case .yearly:
            return "1Y"
        case .all:
            return "1Y"
        }
    }
}

private enum TimeIntervalConstants {
    static let lastHour: TimeInterval = Date().timeIntervalSince1970 - (60 * 60)
    static let yesterday: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24)
    static let lastWeek: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)
    static let lastMonth: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24 * 7 * 30)
    static let lastYear: TimeInterval = Date().timeIntervalSince1970 - (60 * 60 * 24 * 7 * 30 * 12)
}
