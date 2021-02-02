//
//  AlgorandAppStoreReviewer.swift

import Foundation

class AlgorandAppStoreReviewer: AppStoreReviewer {
    
    private let appReviewTriggerCount = 20
    
    func startAppStoreReviewRequestContidition() {
        let openAppCount = UserDefaults.standard.integer(forKey: AppStoreReviewKeys.reviewConditionKey.rawValue) + 1
        UserDefaults.standard.set(openAppCount, forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
    }
    
    func canAskForAppStoreReview() -> Bool {
        let appOpenCount = UserDefaults.standard.integer(forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
        return appOpenCount == appReviewTriggerCount
    }
    
    func updateAppStoreReviewConditionAfterRequest() {
        UserDefaults.standard.set(0, forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
    }
}
