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

import CryptoKit
import Foundation
import LiquidAuthSDK
import SwiftCBOR
import UIKit

public protocol LiquidAuthSDKAPI {
    var signalService: SignalService { get }
    
    func decodeBase64Url(_ url: String) -> Data?
    func decodeBase64UrlToJSON(_ url: String) -> String?
    
    func postAttestationOptions(origin: String, username: String) async throws -> Data
    func postAttestationResult(origin: String, credential: [String: Any], liquidExt: [String: Any]) async throws -> Data
    func postAssertionOptions(origin: String, credentialId: String) async throws -> Data
    func postAssertionResult(origin: String, credential: String, liquidExt: [String: Any]) async throws -> Data
    func getAssertionObject(rpIdHash: Data, userPresent: Bool, userVerified: Bool, backupEligible: Bool, backupState: Bool, signCount: UInt32) -> Data
    func getAttestationObject(credentialId: Data, keyPair: P256.Signing.PrivateKey, rpIdHash: Data) throws -> Data
}

public final class LiquidAuthSDKAPIImpl: LiquidAuthSDKAPI {
    
    public private(set) var signalService: SignalService
    private let userAgent: String
    
    public init(signalService: SignalService? = nil) {
        self.signalService = signalService ?? SignalService.shared
        self.userAgent = UserAgentHeader().value ?? "Unknown"
    }
}

public extension LiquidAuthSDKAPIImpl {
    
    func postAttestationOptions(origin: String, username: String) async throws -> Data {
        let attestationApi = AttestationApi()
        let (data, _) = try await attestationApi.postAttestationOptions(
            origin: origin,
            userAgent: self.userAgent,
            options: [
                "username": username,
                "displayName": "Liquid Auth User",
                "authenticatorSelection": ["userVerification": "required"],
                "extensions": ["liquid": true],
            ]
        )
        
        return data
    }
    
    func postAttestationResult(origin: String, credential: [String: Any], liquidExt: [String: Any]) async throws -> Data {
        let device = await UIDevice.current.model
        let attestationApi = AttestationApi()
        return try await attestationApi.postAttestationResult(
            origin: origin,
            userAgent: self.userAgent,
            credential: credential,
            liquidExt: liquidExt,
            device: device
        )
    }
    
    func postAssertionOptions(origin: String, credentialId: String) async throws -> Data {
        let assertionApi = AssertionApi()
        let (data, _) = try await assertionApi.postAssertionOptions(
            origin: origin,
            userAgent: self.userAgent,
            credentialId: credentialId
        )
        return data
    }
    
    func postAssertionResult(origin: String, credential: String, liquidExt: [String: Any]) async throws -> Data {
        let assertionApi = AssertionApi()
        return try await assertionApi.postAssertionResult(
            origin: origin,
            userAgent: userAgent,
            credential: credential,
            liquidExt: liquidExt
        )
    }
    
    func getAssertionObject(rpIdHash: Data, userPresent: Bool, userVerified: Bool, backupEligible: Bool, backupState: Bool, signCount: UInt32) -> Data {
        AuthenticatorData.assertion(
            rpIdHash: rpIdHash,
            userPresent: userPresent,
            userVerified: userVerified,
            backupEligible: backupEligible,
            backupState: backupState,
            signCount: signCount
        ).toData()
    }
    
    func decodeBase64Url(_ url: String) -> Data? {
        Utility.decodeBase64Url(url)
    }
    
    func decodeBase64UrlToJSON(_ url: String) -> String? {
        Utility.decodeBase64UrlToJSON(url)
    }
    
    func getAttestationObject(credentialId: Data, keyPair: P256.Signing.PrivateKey, rpIdHash: Data) throws -> Data {
        let attestedCredData = Utility.getAttestedCredentialData(
            aaguid: PassKeyService.AAGUID,
            credentialId: credentialId,
            publicKey: keyPair.publicKey.rawRepresentation
        )
        
        let authData = AuthenticatorData.attestation(
            rpIdHash: rpIdHash,
            userPresent: true,
            userVerified: true,
            backupEligible: true,
            backupState: true,
            signCount: 0,
            attestedCredentialData: attestedCredData,
            extensions: nil
        ).toData()

        let attObj: [String: Any] = [
            "attStmt": [:],
            "authData": authData,
            "fmt": "none",
        ]
        let cborEncoded = try CBOR.encodeMap(attObj)
        return Data(cborEncoded)
    }
}

