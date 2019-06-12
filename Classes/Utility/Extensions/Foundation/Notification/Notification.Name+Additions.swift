//
//  Notification.Name+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let AuthenticatedUserUpdate = Notification.Name("com.algorand.algorand.notification.authenticated.user.update")
    static let ApplicationWillEnterForeground = Notification.Name("com.algorand.algorand.notification.application.WillEnterForeground")
    static let AccountUpdate = Notification.Name("com.algorand.algorand.notification.account.update")
    static let ContactAddition = Notification.Name("com.algorand.algorand.notification.contact.addition")
    static let ContactEdit = Notification.Name("com.algorand.algorand.notification.contact.edit")
    static let ContactDeletion = Notification.Name("com.algorand.algorand.notification.contact.deletion")
    static let CoinlistConnected = Notification.Name("com.algorand.algorand.notification.coinlist.connected")
    static let CoinlistDisconnected = Notification.Name("com.algorand.algorand.notification.coinlist.disconnected")
}
