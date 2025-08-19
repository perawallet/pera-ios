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

import pera_wallet_core

extension Session {
    var userInterfaceStyle: UserInterfaceStyle {
        get {
            guard let appearance = string(with: userInterfacePrefenceKey, to: .defaults),
                  let appearancePreference = UserInterfaceStyle(rawValue: appearance) else {
                return .system
            }
            return appearancePreference
        }
        set {
            self.save(newValue.rawValue, for: userInterfacePrefenceKey, to: .defaults)
        }
    }
}
