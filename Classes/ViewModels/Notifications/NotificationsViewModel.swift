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
    private(set) var title: NSAttributedString?
    private var time: String?
    private var isRead: Bool = true
    
    init(notification: NotificationMessage, account: Account? = nil, contact: Contact? = nil) {
        self.notification = notification
        self.account = account
        self.contact = contact
        setImage()
        setTitle()
        setTime()
        setIsRead()
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
        guard let notificationDetail = notification.detail,
            let notificationType = notification.notificationType else {
            title = NSAttributedString(string: notification.message ?? "")
            return
        }
        
        let sender = getSenderInformationFromLocalValues(in: notificationDetail) ?? ""
        let receiver = getReceiverInformationFromLocalValues(in: notificationDetail) ?? ""
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
    
    private func setTime() {
        time = (Date() - notification.date).ago.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
    }
    
    private func setIsRead() {
        guard let notificationLatestFetchTimestamp = UIApplication.shared.appConfiguration?.session.notificationLatestFetchTimestamp else {
            isRead = false
            return
        }
        
        isRead = notification.date.timeIntervalSince1970 < notificationLatestFetchTimestamp
    }
}

extension NotificationsViewModel {
    private func getSenderInformationFromLocalValues(in notificationDetail: NotificationDetail) -> String? {
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
    
    private func getReceiverInformationFromLocalValues(in notificationDetail: NotificationDetail) -> String? {
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
            let assetDisplayName = isUnknown ? "title-unknown".localized : "\(asset.name ?? "") \(asset.code ?? ""))"
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
