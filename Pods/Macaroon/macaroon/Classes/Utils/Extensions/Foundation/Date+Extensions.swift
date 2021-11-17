// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension TimeInterval {
    public func convertToCountdown(
        _ unit: CountdownUnit
    ) -> String {
        switch unit {
        case .hours:
            /// <note>
            /// XX:XX:XX
            return String(
                format: "%02d:%02d:%02d",
                Int(self / 360), /// hours
                Int(self) / 60, /// mins
                Int(truncatingRemainder(dividingBy: 60)) /// secs
            )
        /// <note>
        /// XX:XX
        case .minutes:
            return String(
                format: "%02d:%02d",
                Int(self) / 60, /// mins
                Int(truncatingRemainder(dividingBy: 60)) /// secs
            )
        /// <note>
        /// XX
        case .seconds:
            return String(
                format: "%02d",
                Int(truncatingRemainder(dividingBy: 60)) /// secs
            )
        }
    }
}

extension TimeInterval {
    public enum CountdownUnit {
        case hours
        case minutes
        case seconds
    }
}
