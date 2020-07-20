//
//  NotificationsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SwiftDate

class NotificationsViewModel {
    
    private let notification: NotificationMessage
    private let contact: Contact?
    private let account: Account?
    
    private var notificationImage: UIImage?
    private(set) var title: String?
    private var time: String?
    
    init(notification: NotificationMessage, account: Account? = nil, contact: Contact? = nil) {
        self.notification = notification
        self.account = account
        self.contact = contact
        setImage()
        setTitle()
        setTime()
    }
    
    private func setImage() {
        if let contact = contact {
            if let imageData = contact.image,
                let image = UIImage(data: imageData) {
                let resizedImage = image.convert(to: CGSize(width: 36.0, height: 36.0))
                notificationImage = resizedImage
            } else {
                notificationImage = img("icon-user-placeholder")
            }
            return
        }
        
        if notification.notificationType == .transactionFailed || notification.notificationType == .assetTransactionFailed {
            notificationImage = img("img-nc-failed")
        } else {
            notificationImage = img("img-nc-success")
        }
    }
    
    private func setTitle() {
        guard let notificationDetail = notification.detail else {
            title = notification.message
            return
        }
        
        var notificationMessage = notification.message
        setAccountNameForAddressIfExists(in: notificationDetail, with: &notificationMessage)
        setContactNameForAddressIfExists(in: notificationDetail, with: &notificationMessage)
        title = notificationMessage
    }
    
    private func setTime() {
        /// <todo> This time calculation will be updated when the api returns the notification time.
        time = (Date() - 5.hours).toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
    }
}

extension NotificationsViewModel {
    private func setAccountNameForAddressIfExists(in notificationDetail: NotificationDetail, with message: inout String) {
        if let account = account,
            let accountName = account.name {
            
            if let senderAddress = notificationDetail.senderAddress,
                account.address == senderAddress {
                message = message.replacingOccurrences(of: senderAddress, with: accountName)
            }
            
            if let receiverAddress = notificationDetail.receiverAddress,
                account.address == receiverAddress {
                message = message.replacingOccurrences(of: receiverAddress, with: accountName)
            }
        }
    }
    
    private func setContactNameForAddressIfExists(in notificationDetail: NotificationDetail, with message: inout String) {
        if let contact = contact,
            let contactAddress = contact.address,
            let contactName = contact.name {
            
            if let senderAddress = notificationDetail.senderAddress,
                contactAddress == senderAddress {
                message = message.replacingOccurrences(of: senderAddress, with: contactName)
            }
            
            if let receiverAddress = notificationDetail.receiverAddress,
                contactAddress == receiverAddress {
                message = message.replacingOccurrences(of: receiverAddress, with: contactName)
            }
        }
    }
}

extension NotificationsViewModel {
    func configure(_ cell: NotificationCell) {
        cell.contextView.setNotificationImage(notificationImage)
        cell.contextView.setTitle(title)
        cell.contextView.setTime(time)
    }
}
