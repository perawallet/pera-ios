//
//  NotificationCell.swift

import UIKit

class NotificationCell: BaseCollectionViewCell<NotificationView> {
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.reset()
    }
    
    static func calculatePreferredSize(_ viewModel: NotificationsViewModel?) -> CGSize {
        return NotificationView.calculatePreferredSize(viewModel, with: Layout<NotificationView.LayoutConstants>()) 
    }
}
