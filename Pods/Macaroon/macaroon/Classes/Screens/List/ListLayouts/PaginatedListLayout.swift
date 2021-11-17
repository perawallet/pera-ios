// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class PaginatedListLayout: UICollectionViewFlowLayout {
    open func horizontalTargetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }

        let collectionViewSize = collectionView.bounds.size
        let centerXOffset = collectionViewSize.width / 2.0
        let expectedCenterX = proposedContentOffset.x + centerXOffset
        let targetRect = CGRect(
            x: proposedContentOffset.x + collectionViewSize.width * 0.25,
            y: proposedContentOffset.y,
            width: collectionViewSize.width * 0.5,
            height: collectionViewSize.height
        )

        let someLayoutAttributesToClosestToCenter =
            layoutAttributesForItem(
                closestTo: expectedCenterX,
                in: targetRect
            )

        guard let layoutAttributesToClosestToCenter = someLayoutAttributesToClosestToCenter else {
            return proposedContentOffset
        }

        let centerLayoutAttributes =
            layoutAttributesForItem(
                closestToProposedLayoutAttributes: layoutAttributesToClosestToCenter,
                forScrollingVelocity: velocity.x
            )

        return CGPoint(
            x: centerLayoutAttributes.center.x - centerXOffset,
            y: proposedContentOffset.y
        )
    }

    open func verticalTargetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }

        let collectionViewSize = collectionView.bounds.size
        let centerYOffset = collectionViewSize.height / 2.0
        let expectedCenterY = proposedContentOffset.y + centerYOffset
        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: proposedContentOffset.y + collectionViewSize.height * 0.25,
            width: collectionViewSize.width,
            height: collectionViewSize.height * collectionViewSize.height * 0.5
        )

        let someLayoutAttributesToClosestToCenter =
            layoutAttributesForItem(
                closestTo: expectedCenterY,
                in: targetRect
            )

        guard let layoutAttributesToClosestToCenter = someLayoutAttributesToClosestToCenter else {
            return proposedContentOffset
        }

        let centerLayoutAttributes =
            layoutAttributesForItem(
                closestToProposedLayoutAttributes: layoutAttributesToClosestToCenter,
                forScrollingVelocity: velocity.y
            )

        return CGPoint(
            x: centerLayoutAttributes.center.y - centerYOffset,
            y: proposedContentOffset.y
        )
    }

    open override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        switch scrollDirection {
        case .horizontal:
            return horizontalTargetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        case .vertical:
            return verticalTargetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        @unknown default:
            return proposedContentOffset
        }
    }
}

extension PaginatedListLayout {
    public func layoutAttributesForItem(
        closestTo point: CGFloat,
        in rect: CGRect
    ) -> UICollectionViewLayoutAttributes? {
        let layoutAttributesInRect =
            layoutAttributesForElements(
                in: rect
            )

        return layoutAttributesInRect?
            .min {
                if $0.representedElementCategory != .cell {
                    return false
                }

                switch scrollDirection {
                case .horizontal: return abs($0.center.x - point) < abs($1.center.x - point)
                case .vertical: return abs($0.center.y - point) < abs($1.center.y - point)
                @unknown default: return false
                }
            }
    }

    public func layoutAttributesForItem(
        closestToProposedLayoutAttributes proposedLayoutAttributes: UICollectionViewLayoutAttributes,
        forScrollingVelocity velocity: CGFloat
    ) -> UICollectionViewLayoutAttributes {
        if abs(velocity) < 0.1 {
            return proposedLayoutAttributes
        }

        let proposedIndexPath = proposedLayoutAttributes.indexPath
        let indexPath =
            IndexPath(
                item: proposedIndexPath.item + (velocity > 0 ? 1 : -1),
                section: proposedIndexPath.section
            )
        let layoutAttributes =
            layoutAttributesForItem(
                at: indexPath
            )

        return layoutAttributes ?? proposedLayoutAttributes
    }
}
