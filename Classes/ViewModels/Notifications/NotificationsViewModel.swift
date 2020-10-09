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
    
    private var notificationImage: UIImage?
    private(set) var title: NSAttributedString?
    private var time: String?
    private var isRead: Bool = true
    
    init(
        notification: NotificationMessage,
        senderAccount: Account? = nil,
        receiverAccount: Account? = nil,
        contact: Contact? = nil,
        latestReadTimestamp: TimeInterval? = nil
    ) {
        setImage(notification: notification, contact: contact)
        setTitle(notification: notification, senderAccount: senderAccount, receiverAccount: receiverAccount, contact: contact)
        setTime(notification: notification)
        setIsRead(notification: notification, latestReadTimestamp: latestReadTimestamp)
    }
    
    private func setImage(notification: NotificationMessage, contact: Contact?) {
        if let contact = contact {
            if let imageData = contact.image,
                let image = UIImage(data: imageData) {
                let resizedImage = image.convert(to: CGSize(width: 36.0, height: 36.0))
                notificationImage = resizedImage
            } else {
                notificationImage = img("icon-user-placeholder-gray")
            }
            return
        }
        
        if notification.notificationType == .transactionFailed || notification.notificationType == .assetTransactionFailed {
            notificationImage = img("img-nc-failed")
        } else {
            notificationImage = img("img-nc-success")
        }
    }
    
    private func setTitle(notification: NotificationMessage, senderAccount: Account?, receiverAccount: Account?, contact: Contact?) {
        guard let notificationDetail = notification.detail,
            let notificationType = notification.notificationType else {
            title = NSAttributedString(string: notification.message ?? "")
            return
        }
        
        let sender = getSenderInformationFromLocalValues(in: notificationDetail, account: senderAccount, contact: contact) ?? ""
        let receiver = getReceiverInformationFromLocalValues(in: notificationDetail, account: receiverAccount, contact: contact) ?? ""
        let assetDisplayName = getAssetDisplayName(from: notificationDetail) ?? ""
        let amount = getAmount(from: notificationDetail) ?? ""
        let assetWithAmount = "\(amount) \(assetDisplayName)"
        
        switch notificationType {
        case .transactionSent,
            .assetTransactionSent:
            let message = "notification-sent-success".localized(params: assetWithAmount, sender, receiver)
            title = getAttributedMessage(message, for: assetWithAmount, sender, receiver)
        case .transactionReceived,
             .assetTransactionReceived:
            let message = "notification-received".localized(params: assetWithAmount, receiver, sender)
            title = getAttributedMessage(message, for: assetWithAmount, receiver, sender)
        case .transactionFailed,
             .assetTransactionFailed:
            let message = "notification-sent-failed".localized(params: assetWithAmount, sender, receiver)
            title = getAttributedMessage(message, for: assetWithAmount, sender, receiver)
        case .assetSupportRequest:
            let message = "notification-support-request".localized(params: sender, assetDisplayName)
            title = getAttributedMessage(message, for: sender, assetDisplayName)
        case .assetSupportSuccess:
            let message = "notification-support-success".localized(params: sender, assetDisplayName)
            title = getAttributedMessage(message, for: sender, assetDisplayName)
        }
    }
    
    private func setTime(notification: NotificationMessage) {
        if let notificationDate = notification.date {
            time = (Date() - notificationDate).ago.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.autoUpdating)
        }
    }
    
    private func setIsRead(notification: NotificationMessage, latestReadTimestamp: TimeInterval?) {
        guard let notificationLatestFetchTimestamp = latestReadTimestamp,
            let notificationDate = notification.date else {
            isRead = false
            return
        }
        
        isRead = notificationDate.timeIntervalSince1970 < notificationLatestFetchTimestamp
    }
}

extension NotificationsViewModel {
    private func getSenderInformationFromLocalValues(
        in notificationDetail: NotificationDetail,
        account: Account?,
        contact: Contact?
    ) -> String? {
        if let account = account,
            let accountName = account.name,
            let senderAddress = notificationDetail.senderAddress,
            account.address == senderAddress {
            return accountName
        } else if let contact = contact,
            let contactAddress = contact.address,
            let contactName = contact.name,
            let senderAddress = notificationDetail.senderAddress,
            contactAddress == senderAddress {
            return contactName
        } else {
            return notificationDetail.senderAddress?.shortAddressDisplay()
        }
    }
    
    private func getReceiverInformationFromLocalValues(
        in notificationDetail: NotificationDetail,
        account: Account?,
        contact: Contact?
    ) -> String? {
        if let account = account,
            let accountName = account.name,
            let receiverAddress = notificationDetail.receiverAddress,
            account.address == receiverAddress {
            return accountName
        } else if let contact = contact,
            let contactAddress = contact.address,
            let contactName = contact.name,
            let receiverAddress = notificationDetail.receiverAddress,
            contactAddress == receiverAddress {
            return contactName
        } else {
            return notificationDetail.receiverAddress?.shortAddressDisplay()
        }
    }
    
    private func getAmount(from notificationDetail: NotificationDetail) -> String? {
        let amount = notificationDetail.amount ?? 0
        if let asset = notificationDetail.asset {
            let fraction = asset.fractionDecimals ?? 0
            return amount.toFractionStringForLabel(fraction: fraction)
        }
        return amount.toAlgos.toDecimalStringForLabel
    }
    
    private func getAssetDisplayName(from notificationDetail: NotificationDetail) -> String? {
        if let asset = notificationDetail.asset {
            let isUnknown = asset.name.isNilOrEmpty && asset.code.isNilOrEmpty
            let assetDisplayName = isUnknown ? "title-unknown".localized : "\(asset.name ?? "") (\(asset.code ?? ""))"
            return assetDisplayName
        }
        return "Algos"
    }
    
    private func getAttributedMessage(_ message: String, for parameters: String...) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: message,
            attributes: [ .font: UIFont.font(withWeight: .regular(size: 14.0)), .foregroundColor: SharedColors.primaryText]
        )
        parameters.forEach { parameter in
            let parameterRange = (message as NSString).range(of: parameter)
            attributedText.addAttributes([.font: UIFont.font(withWeight: .medium(size: 14.0))], range: parameterRange)
        }
        return attributedText
    }
}

extension NotificationsViewModel {
    func configure(_ cell: NotificationCell) {
        cell.contextView.setNotificationImage(notificationImage)
        cell.contextView.setAttributedTitle(title)
        cell.contextView.setTime(time)
        cell.contextView.setBadgeHidden(isRead)
    }
}
