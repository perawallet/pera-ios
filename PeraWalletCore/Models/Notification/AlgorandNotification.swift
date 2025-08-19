// Copyright 2022-2025 Pera Wallet, LDA

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
//  AlgorandNotification.swift

import Foundation
import MacaroonUtils

public final class AlgorandNotification: JSONModel {
    public let badge: Int?
    public let alert: String?
    public let detail: AlgorandNotificationDetail?
    public let sound: String?

    public init() {
        self.badge = nil
        self.alert = nil
        self.detail = nil
        self.sound = nil
    }
}

extension AlgorandNotification {
    private enum CodingKeys:
        String,
        CodingKey {
        case badge
        case alert
        case detail = "custom"
        case sound
    }
}
