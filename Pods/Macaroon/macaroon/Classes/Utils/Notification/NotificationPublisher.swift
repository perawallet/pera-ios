// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol NotificationPublisher { }

extension NotificationPublisher {
    public func post(notificationWith name: Notification.Name) {
        NotificationCenter.default.post(Notification(name: name))
    }
}
