//
//  NotificationFilterListLayout.swift

import UIKit

class NotificationFilterListLayout: NSObject {

    weak var delegate: LedgerAccountSelectionListLayoutDelegate?

    private let layout = Layout<LayoutConstants>()

    private weak var dataSource: NotificationFilterDataSource?

    init(dataSource: NotificationFilterDataSource) {
        self.dataSource = dataSource
        super.init()
    }
}

extension NotificationFilterListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 || dataSource?.isEmpty ?? false {
            return .zero
        }

        return layout.current.headerSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if section == 0 {
            return layout.current.sectionInset
        }
        
        return .zero
    }
}

extension NotificationFilterListLayout {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: 72.0)
        let headerSize = CGSize(width: UIScreen.main.bounds.width, height: 60.0)
        let sectionInset = UIEdgeInsets(top: 12.0, left: 0, bottom: 0, right: 0)
    }
}
