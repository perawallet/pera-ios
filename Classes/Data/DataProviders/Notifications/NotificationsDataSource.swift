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
    private var lastRequest: EndpointOperatable?

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
                self.notifications = notifications
            case .failure:
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
                let notification = notifications[safe: indexPath.item] {
                let viewModel = NotificationsViewModel(notification: notification)
                viewModel.configure(cell)
                return cell
            }
        }
        fatalError("Index path is out of bounds")
    }
}

extension NotificationsDataSource {
    var isEmpty: Bool {
        return notifications.isEmpty
    }
    
    func notification(at index: Int) -> NotificationMessage? {
        return notifications[safe: index]
    }
}
