// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CarouselFlowLayout.swift

import UIKit

final class CarouselFlowLayout: UICollectionViewFlowLayout {
    private let itemWidthRatio: CGFloat = 0.88
    
    init(spacing: CGFloat, insets: UIEdgeInsets) {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = spacing
        sectionInset = insets
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        let height = cv.bounds.height
        let width = cv.bounds.width * itemWidthRatio
        itemSize = CGSize(width: width, height: height)
    }

    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let cv = collectionView else { return proposedContentOffset }

        let horizontalOffset = proposedContentOffset.x + cv.contentInset.left

        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: 0,
            width: cv.bounds.size.width,
            height: cv.bounds.size.height
        )

        let layoutAttributes = layoutAttributesForElements(in: targetRect) ?? []

        let closestAttribute = layoutAttributes.min {
            abs($0.frame.origin.x - horizontalOffset) < abs($1.frame.origin.x - horizontalOffset)
        }

        guard let closest = closestAttribute else {
            return proposedContentOffset
        }

        let offsetX = closest.frame.origin.x - cv.contentInset.left
        return CGPoint(x: offsetX, y: proposedContentOffset.y)
    }
}
