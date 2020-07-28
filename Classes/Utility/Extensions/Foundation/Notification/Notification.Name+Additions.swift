//
//  Notification.Name+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
}
