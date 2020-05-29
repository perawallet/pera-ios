//
//  UICollectionView+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UICollectionView {
    var isEmpty: Bool {
        if numberOfSections == 0 {
            return true
        }
        
        for section in 0..<numberOfSections {
            if numberOfItems(inSection: section) > 0 {
                return false
            }
        }
        
        return true
    }
    
    //swiftlint:disable implicit_getter
    var contentState: ContentStateView.State {
        get {
            return (backgroundView as? ContentStateView).map { $0.state } ?? .none
        }
        set {
            (backgroundView as? ContentStateView)?.state = newValue
        }
    }
    //swiftlint:enable implicit_getter
    
    func reloadSection(_ section: Int) {
        reloadSections(IndexSet(integersIn: section...section))
    }
}
