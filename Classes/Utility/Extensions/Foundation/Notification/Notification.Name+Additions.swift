//
//  Notification.Name+Additions.swift

import Foundation

extension Notification.Name {
    static var AuthenticatedUserUpdate: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.authenticated.user.update")
    }

    static var ApplicationWillEnterForeground: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.application.WillEnterForeground")
    }

    static var AccountUpdate: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.account.update")
    }
    
    static var ContactAddition: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.contact.addition")
    }

    static var ContactEdit: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.contact.edit")
    }

    static var ContactDeletion: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.contact.deletion")
    }
    
    static var NetworkChanged: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.network.change")
    }
    
    static var DeviceIDDidSet: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.device.id.set")
    }
    
    static var NotificationDidReceived: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.received")
    }
}
