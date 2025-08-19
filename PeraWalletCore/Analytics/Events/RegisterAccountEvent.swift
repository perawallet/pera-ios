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
//  RegisterAccountEvent.swift

import Foundation
import MacaroonVendors

public struct RegisterAccountEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        registrationType: RegistrationType
    ) {
        self.name = .registerAccount
        self.metadata = [
            .accountCreationType: registrationType.rawValue
        ]
    }
}

extension AnalyticsEvent where Self == RegisterAccountEvent {
    public static func registerAccount(
        registrationType: RegisterAccountEvent.RegistrationType
    ) -> Self {
        return RegisterAccountEvent(registrationType: registrationType)
    }
}

extension RegisterAccountEvent {
    public enum RegistrationType: String {
        case create = "create"
        case ledger = "ledger"
        case recover = "recover"
        case rekeyed = "rekeyed"
        case watch = "watch"
        
        public static func ==(lhs: RegistrationType, rhs: RegistrationType) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}
