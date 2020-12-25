//
//  AppStoreReviewer.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import StoreKit

protocol AppStoreReviewer: class {
    typealias APPID = String
    
    func requestReviewIfAppropriate()
    func requestManualReview(forAppWith id: APPID)
    
    func startAppStoreReviewRequestContidition()
    func canAskForAppStoreReview() -> Bool
}

extension AppStoreReviewer {
    func requestReviewIfAppropriate() {
        startAppStoreReviewRequestContidition()

        if !isCurrentVersionAskedForAppStoreReview() && canAskForAppStoreReview() {
            SKStoreReviewController.requestReview()
            updateLatestVersionForAppStoreReview()
        }
    }
    
    func requestManualReview(forAppWith id: APPID) {
        if let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(id)?action=write-review") {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}

extension AppStoreReviewer {
    /// <note> App review prompt should not be displayed to the user more than one time for the same app version.
    private func isCurrentVersionAskedForAppStoreReview() -> Bool {
        if let currentAppVersion = getCurrentAppVersion(),
           let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: AppStoreReviewKeys.lastVersionKey.rawValue) {
            return currentAppVersion == lastVersionPromptedForReview
        }
        
        return false
    }
    
    private func updateLatestVersionForAppStoreReview() {
        if let currentAppVersion = getCurrentAppVersion() {
            UserDefaults.standard.set(currentAppVersion, forKey: AppStoreReviewKeys.lastVersionKey.rawValue)
        }
    }
    
    private func getCurrentAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

enum AppStoreReviewKeys: String {
    case reviewConditionKey = "review.condition.value"
    case lastVersionKey = "last.version.reviewed"
}
