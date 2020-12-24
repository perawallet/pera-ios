//
//  AlgorandAppStoreReviewer.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

class AlgorandAppStoreReviewer: AppStoreReviewer {
    
    private let appReviewTriggerCount = 20
    
    func startAppStoreReviewRequestContidition() {
        let openAppCount = UserDefaults.standard.integer(forKey: AppStoreReviewKeys.reviewConditionKey.rawValue) + 1
        UserDefaults.standard.set(openAppCount, forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
    }
    
    func canAskForAppStoreReview() -> Bool {
        let appOpenCount = UserDefaults.standard.integer(forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
        return appOpenCount >= appReviewTriggerCount
    }
}
