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
        
        let translation = scrollView.panGestureRecognizer.translation(in: view)
        
        if translation.y < 0 {
            let offset = scrollView.contentOffset.y + headerHeight
            
            let offsetDifference = headerHeight - offset
            
            if offsetDifference <= AssetDetailView.LayoutConstants.smallHeaderHeight {
                adjustSmallHeaderViewLayout()
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.smallHeaderHeight
            } else {
                assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offsetDifference)
                }
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = offsetDifference
                
                let progress: CGFloat = offsetDifference / headerHeight
                
                UIView.animate(withDuration: 0.0) {
                    self.assetDetailView.headerView.alpha = progress
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            let offset = -scrollView.contentOffset.y
            
            let offsetTotal = AssetDetailView.LayoutConstants.smallHeaderHeight + offset
            
            if offsetTotal >= headerHeight {
                adjustDefaultHeaderViewLayout()
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = headerHeight
            } else {
                let offset = max(-scrollView.contentOffset.y, AssetDetailView.LayoutConstants.smallHeaderHeight)
                
                let progress: CGFloat = offset / headerHeight
                
                assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
                    make.height.equalTo(offset)
                }
                
                assetDetailView.transactionHistoryCollectionView.contentInset.top = offset
                
                UIView.animate(withDuration: 0.33) {
                    self.assetDetailView.headerView.alpha = progress
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if transactionHistoryDataSource.transactionCount() == 0 {
            return
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: view)
        
        if translation.y < 0 {
            let offset = scrollView.contentOffset.y + headerHeight
            
            let offsetDifference = headerHeight - offset
            
            if offsetDifference <= AssetDetailView.LayoutConstants.smallHeaderHeight {
                return
            }
            
            adjustSmallHeaderViewLayout(withContentInsetUpdate: true)
            
        } else {
            let offset = scrollView.contentInset.top + scrollView.contentOffset.y + AssetDetailView.LayoutConstants.smallHeaderHeight
            
            if offset > headerHeight {
                return
            }
            
            adjustDefaultHeaderViewLayout(withContentInsetUpdate: true)
        }
        
    }
    
    private func adjustSmallHeaderViewLayout(withContentInsetUpdate shouldUpdateContentInset: Bool = false) {
        assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(AssetDetailView.LayoutConstants.smallHeaderHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.assetDetailView.headerView.alpha = 0.0
            self.assetDetailView.smallHeaderView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.assetDetailView.transactionHistoryCollectionView.contentInset.top = AssetDetailView.LayoutConstants.smallHeaderHeight
                self.assetDetailView.transactionHistoryCollectionView.contentOffset.y = -AssetDetailView.LayoutConstants.smallHeaderHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    func adjustDefaultHeaderViewLayout(withContentInsetUpdate shouldUpdateContentInset: Bool = false) {
        assetDetailView.accountsHeaderContainerView.snp.updateConstraints { make in
            make.height.equalTo(headerHeight)
        }
        
        UIView.animate(withDuration: 0.33) {
            self.assetDetailView.smallHeaderView.alpha = 0.0
            self.assetDetailView.headerView.alpha = 1.0
            
            if shouldUpdateContentInset {
                self.assetDetailView.transactionHistoryCollectionView.contentInset.top = self.headerHeight
                self.assetDetailView.transactionHistoryCollectionView.contentOffset.y = -self.headerHeight
            }
            
            self.view.layoutIfNeeded()
        }
    }
}
