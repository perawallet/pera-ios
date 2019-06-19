//
//  LeftAlignedCollectionViewFlowLayout.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
