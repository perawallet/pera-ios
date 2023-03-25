// Copyright 2022 Pera Wallet, LDA

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
//  LocalAuthenticator.swift

import Foundation

/// <todo>: Change name as `BiometricAuthenticator`
/// <mark>: LocalAuthenticator
/// Local authenticator does biometric authentication with using KeychainAccess through `session`
class LocalAuthenticator {
    private let session: Session?

    init(session: Session?) {
        self.session = session
    }
}

/// <mark>: API
extension LocalAuthenticator {
    func hasAuthentication() -> Bool {
        guard let session else {
            return false
        }

        return session.hasBiometricPassword()
    }

    func authenticate() throws {
        guard let session else {
            throw LAError.invalidSession
        }

        if session.hasBiometricPassword() {
            try session.checkBiometricPassword()
            return
        }

        throw LAError.biometricNotSet
    }

    func setBiometricPassword() throws {
        guard let session else {
            throw LAError.invalidSession
        }

        try session.setBiometricPassword()
    }

    func removeBiometricPassword() throws {
        guard let session else {
            throw LAError.invalidSession
        }

        try session.removeBiometricPassword()
    }
}

enum LAError: Error {
    /// <note> Thrown when a session object is not passed in `LocalAuthenticator`.
    case invalidSession
    /// <note> Thrown when the app password is not set.
    case passwordNotSet
    /// <note> Thrown when the app password does not match the password in biometric storage.
    case passwordMismatch
    /// <note> Thrown when biometric authentication is not set
    case biometricNotSet
    /// <note> Thrown when other errors are thrown by the system.
    case other(Error)
}
