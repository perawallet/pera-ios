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
//  PinLimitStore.swift

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
