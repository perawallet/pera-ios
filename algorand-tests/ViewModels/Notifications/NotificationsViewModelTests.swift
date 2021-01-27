//
//  NotificationsViewModelTests.swift
//  algorand-tests
//
//  Created by Göktuğ Berk Ulu on 7.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import XCTest

@testable import algorand_staging

class NotificationsViewModelTests: XCTestCase {

    private let notification = Bundle.main.decode(NotificationMessage.self, from: "NotificationMessage.json")
    private let account = Bundle.main.decode(Account.self, from: "AccountA.json")

    func testNotificationMessageSenderAccount() {
        let viewModel = NotificationsViewModel(notification: notification, senderAccount: account, latestReadTimestamp: 3000)
        XCTAssertEqual(viewModel.title?.string, "Your transaction of 55.555555 Algos from Chase to MF5KP5...RGQRHI is complete.")
    }

    func testNotificationMessageReceiverAccount() {
        let viewModel = NotificationsViewModel(notification: notification, receiverAccount: account, latestReadTimestamp: 3000)
        XCTAssertEqual(viewModel.title?.string, "Your transaction of 55.555555 Algos from T4EWBD...UU6QRM to MF5KP5...RGQRHI is complete.")
    }

    func testIsRead() {
        let viewModel = NotificationsViewModel(notification: notification, senderAccount: account, latestReadTimestamp: 3000)
        XCTAssertFalse(viewModel.isRead)
    }
}
