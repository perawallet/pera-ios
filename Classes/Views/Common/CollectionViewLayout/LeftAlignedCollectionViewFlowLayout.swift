// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LeftAlignedCollectionViewFlowLayout.swift

import UIKit

protocol LeftAlignedCollectionViewFlowLayoutDelegate: class {
    func leftAlignedLayout(_ layout: LeftAlignedCollectionViewFlowLayout,
                           sizeFor indexPath: IndexPath) -> CGSize
    func leftAlignedLayoutDidCalculateHeight(_ height: CGFloat)
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var height: CGFloat = 0.0
    weak var delegate: LeftAlignedCollectionViewFlowLayoutDelegate?
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = self.collectionView,
            let delegate = self.delegate else {
            return
        }
        
        var leftMargin = sectionInset.left
        var topMargin = sectionInset.top
        let collectionWidth = collectionView.frame.width
        
        if cache.isEmpty {
            for item in 0..<collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let size = delegate.leftAlignedLayout(self, sizeFor: indexPath)
                
                let frame = CGRect(x: leftMargin, y: topMargin, width: size.width, height: size.height)
                
                if item == 0 {
                    height = size.height
                }
                
                if leftMargin == sectionInset.left {
                    layoutAttribute.frame = frame
                } else {
                    if collectionWidth - size.width - leftMargin < 0 {
                        leftMargin = sectionInset.left
                        topMargin += size.height + minimumLineSpacing
                        height += size.height + minimumLineSpacing
                    }
                    let frame = CGRect(x: leftMargin, y: topMargin, width: size.width, height: size.height)
                    
                    layoutAttribute.frame = frame
                }
                
                leftMargin += size.width + minimumInteritemSpacing
                
                cache.append(layoutAttribute)
            }
            
            height += sectionInset.bottom + minimumLineSpacing
            
            delegate.leftAlignedLayoutDidCalculateHeight(height)
        }
    }
    
    override func invalidateLayout() {
        cache.removeAll()
        super.invalidateLayout()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
