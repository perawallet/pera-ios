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
    
    weak var delegate: NotificationsDataSourceDelegate?

    init(api: API) {
        self.api = api
        super.init()
        startObserving()
    }
}

extension NotificationsDataSource {
    func loadData() {
        guard let deviceId = api.session.deviceId else {
            return
        }
        
        lastRequest = api.getNotifications(for: deviceId) { response in
            switch response {
            case let .success(notifications):
                self.notifications = notifications.results
                
                self.viewModels.removeAll()
                notifications.results.forEach { notification in
                    self.viewModels.append(self.formViewModel(from: notification))
                }
                
                self.delegate?.notificationsDataSource(self, didFetch: notifications.results)
            case let .failure(error):
                self.delegate?.notificationsDataSource(self, didFailWith: error)
            }
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
                
                self.contacts.append(contentsOf: results)
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
            name: .DeviceIDSet,
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
                let viewModel = viewModels[safe: indexPath.item] {
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
}

protocol NotificationsDataSourceDelegate: class {
    func notificationsDataSource(_ notificationsDataSource: NotificationsDataSource, didFetch notifications: [NotificationMessage])
    func notificationsDataSource(_ notificationsDataSource: NotificationsDataSource, didFailWith error: Error)
}
