//
//  PinLimitStore.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct PinLimitStore: Storable {
    typealias Object = Any
    
    private let attemptCountKey = "com.algorand.algorand.pin.limit.attempt.key"
    private let remainingTimeKey = "com.algorand.algorand.pin.limit.remaining.time"
    
    let allowedAttemptLimitCount = 5
    
    var attemptCount: Int {
        return userDefaults.integer(forKey: attemptCountKey)
    }
    
    var remainingTime: Int {
        return userDefaults.integer(forKey: remainingTimeKey)
    }
    
    mutating func increasePinAttemptCount() {
        userDefaults.set(attemptCount + 1, forKey: attemptCountKey)
    }
    
    mutating func resetPinAttemptCount() {
        userDefaults.set(0, forKey: attemptCountKey)
    }
    
    mutating func setRemainingTime(_ time: Int) {
        userDefaults.set(time, forKey: remainingTimeKey)
    }
    
    mutating func resetRemainingTime(_ time: Int) {
        userDefaults.set(0, forKey: remainingTimeKey)
    }
}
