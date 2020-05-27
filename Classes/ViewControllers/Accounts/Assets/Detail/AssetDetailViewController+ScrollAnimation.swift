//
//  AssetDetailViewController+ScrollAnimation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

extension AssetDetailViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
}
