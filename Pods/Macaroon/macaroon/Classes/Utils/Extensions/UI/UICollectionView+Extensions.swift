// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UICollectionView {
    public var flowLayout: UICollectionViewFlowLayout {
        guard let someFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            mc_crash(
                .unsupportedListLayout
            )
        }

        return someFlowLayout
    }
}

extension UICollectionView {
    public func register(_ someClass: (UICollectionViewCell & ListIdentifiable).Type) {
        register(someClass, forCellWithReuseIdentifier: someClass.reuseIdentifier)
    }

    public func register(_ someClass: (UICollectionReusableView & ListIdentifiable).Type, forSupplementaryViewOfKind kind: String) {
        register(someClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: someClass.reuseIdentifier)
    }

    public func register(header someClass: (UICollectionReusableView & ListIdentifiable).Type) {
        register(someClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    }

    public func register(footer someClass: (UICollectionReusableView & ListIdentifiable).Type) {
        register(someClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter)
    }
}

extension UICollectionView {
    public func dequeue<T: UICollectionViewCell>(_ someClass: T.Type, at indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: someClass.reuseIdentifier, for: indexPath) as? T else {
            mc_crash(.unsupportedListCell(T.self))
        }

        return cell
    }
}

extension UICollectionView {
    public func indexPathForItemAtCenter() -> IndexPath? {
        let centerPoint = CGPoint(x: contentOffset.x + center.x, y: contentOffset.y + center.y)

        return indexPathForItem(
            at: centerPoint
        )
    }
}
