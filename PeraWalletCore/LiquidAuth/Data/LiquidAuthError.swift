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

//   PassKeyError.swift

public enum LiquidAuthError : LocalizedError {
    case generalError
    case notImplemented
    case signingAccountNotFound
    case passKeyExists
    case passKeyNotFound
    case passKeyInvalid
    case authenticationFailed
    
    public var errorDescription: String? {
        switch self {
        case .generalError:
            return String(localized: "liquid-auth-error")
        case .notImplemented:
            return String(localized: "liquid-auth-not-implemented")
        case .signingAccountNotFound:
            return String(localized: "liquid-auth-no-account-found")
        case .passKeyExists:
            return String(localized: "liquid-auth-passkey-already-exists")
        case .passKeyNotFound:
            return String(localized: "liquid-auth-no-passkey-found")
        case .passKeyInvalid:
            return String(localized: "liquid-auth-invalid-passkey-found")
        case .authenticationFailed:
            return String(localized: "local-authentication-failed")
        }
    }
}
