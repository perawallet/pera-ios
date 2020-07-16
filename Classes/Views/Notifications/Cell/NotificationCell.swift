//
//  NotificationCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NotificationCell: BaseCollectionViewCell<NotificationView> {
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.reset()
    }
    
    static func calculatePreferredSize(_ viewModel: NotificationsViewModel) -> CGSize {
        return NotificationView.calculatePreferredSize(viewModel, with: Layout<NotificationView.LayoutConstants>()) 
    }
}
