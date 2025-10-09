// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Scout
import Foundation
import CryptoKit
import LiquidAuthSDK
@testable import pera_staging
@testable import pera_wallet_core

final class MockFeatureFlagService : FeatureFlagServicing, Mockable {
    
    var mock = Mock()
    
    func fetchAndActivate() async throws {
        try! mock.call.fetchAndActivate()
    }
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        try! mock.call.isEnabled(flag: flag) as! Bool
    }
    
    func double(for flag: pera_wallet_core.FeatureFlag) -> Double? {
        return 0.665
    }
}
