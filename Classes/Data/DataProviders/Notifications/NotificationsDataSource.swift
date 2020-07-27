//
//  NotificationsDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import Magpie

class NotificationsDataSource: NSObject {
    
    private let api: API
    private var notifications = [NotificationMessage]()
    private var viewModels = [NotificationsViewModel]()
    private var contacts = [Contact]()
    private var lastRequest: EndpointOperatable?
    
    private let paginationRequestThreshold = 3
    private var paginationCursor: String?
    var hasNext: Bool {
        return paginationCursor != nil
    }
    
    weak var delegate: NotificationsDataSourceDelegate?

    init(api: API) {
        self.api = api
        super.init()
        startObserving()
    }
}

extension NotificationsDataSource {
    func loadData(withRefresh refresh: Bool = true, isPaginated: Bool = false) {
        guard let deviceId = api.session.authenticatedUser?.deviceId else {
            delegate?.notificationsDataSourceDidFailToFetch(self)
            return
        }
        
        lastRequest = api.getNotifications(for: deviceId, with: CursorQuery(cursor: paginationCursor)) { response in
            switch response {
            case let .success(notifications):
                if refresh {
                    self.clear()
                }
                
                self.api.session.notificationLatestFetchTimestamp = Date().timeIntervalSince1970
                self.setCursor(from: notifications)
                
                if isPaginated {
                    self.notifications.append(contentsOf: notifications.results)
                } else {
                    self.notifications = notifications.results
                }
                
                notifications.results.forEach { notification in
                    self.viewModels.append(self.formViewModel(from: notification))
                }
                
                self.delegate?.notificationsDataSourceDidFetchNotifications(self)
            case let .failure(error):
                self.delegate?.notificationsDataSourceDidFailToFetch(self)
            }
        }
    }
    
    private func setCursor(from notifications: PaginatedList<NotificationMessage>) {
        if let next = notifications.next,
            let cursor = next.queryParameters?[RequestParameter.cursor.rawValue] {
            paginationCursor = cursor
        } else {
            paginationCursor = nil
        }
    }
}

extension NotificationsDataSource {
    func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts = results
            default:
                break
            }
        }
    }
}

extension NotificationsDataSource {
    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeviceIDSet(notification:)),
            name: .DeviceIDDidSet,
            object: nil
        )
    }
    
    @objc
    private func didDeviceIDSet(notification: Notification) {
        if lastRequest == nil {
            loadData()
        }
    }
}

extension NotificationsDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < notifications.count {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NotificationCell.reusableIdentifier,
                for: indexPath
            ) as? NotificationCell,
                let viewModel = viewModel(at: indexPath.item) {
                viewModel.configure(cell)
                return cell
            }
        }
        fatalError("Index path is out of bounds")
    }
    
    private func formViewModel(from notification: NotificationMessage) -> NotificationsViewModel {
        return NotificationsViewModel(
            notification: notification,
            account: getAccountIfExists(for: notification),
            contact: getContactIfExists(for: notification)
        )
    }
    
    private func getAccountIfExists(for notification: NotificationMessage) -> Account? {
        guard let details = notification.detail else {
            return nil
        }
        
        return api.session.accounts.first { $0.address == details.senderAddress || $0.address == details.receiverAddress }
    }
    
    private func getContactIfExists(for notification: NotificationMessage) -> Contact? {
        guard let details = notification.detail else {
            return nil
        }
        
        return contacts.first { contact -> Bool in
            if let contactAddress = contact.address {
                return contactAddress == details.senderAddress || contactAddress == details.receiverAddress
            }
            return false
        }
    }
}

extension NotificationsDataSource {
    var isEmpty: Bool {
        return notifications.isEmpty
    }
    
    func notification(at index: Int) -> NotificationMessage? {
        return notifications[safe: index]
    }
    
    func viewModel(at index: Int) -> NotificationsViewModel? {
        return viewModels[safe: index]
    }
    
    func shouldSendPaginatedRequest(at index: Int) -> Bool {
        return index == notifications.count - paginationRequestThreshold && hasNext
    }
    
    func clear() {
        lastRequest?.cancel()
        lastRequest = nil
        viewModels.removeAll()
        notifications.removeAll()
        paginationCursor = nil
    }
    
    func getUserAccount(from notificationDetail: NotificationDetail) -> (account: Account?, assetDetail: AssetDetail?) {
        guard let account = api.session.accounts.first(where: { account -> Bool in
            account.address == notificationDetail.senderAddress || account.address == notificationDetail.receiverAddress
        }) else {
            return (account: nil, assetDetail: nil)
        }
        
        var assetDetail: AssetDetail?
        if let assetId = notificationDetail.asset?.id {
            assetDetail = account.assetDetails.first { $0.id == assetId }
        }
        return (account: account, assetDetail: assetDetail)
    }
}

protocol NotificationsDataSourceDelegate: class {
    func notificationsDataSourceDidFetchNotifications(_ notificationsDataSource: NotificationsDataSource)
    func notificationsDataSourceDidFailToFetch(_ notificationsDataSource: NotificationsDataSource)
}
