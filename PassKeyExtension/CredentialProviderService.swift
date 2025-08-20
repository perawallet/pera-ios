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

import AuthenticationServices
import LocalAuthentication
import Firebase
import SwiftCBOR
import UIKit
import CoreData
import pera_wallet_core
import LiquidAuthSDK
import SwiftUI
import CryptoKit

@available(iOS 17, *)
final class CredentialProviderService {
    private let liquidAuthSDK: LiquidAuthSDKAPI = LiquidAuthSDKAPIImpl()
    private var passKeyManager: PassKeyService?
    
    func handleRegistrationRequest(_ credentialRequest: ASPasskeyCredentialRequest) async throws(pera_wallet_core.LiquidAuthError) -> ASPasskeyRegistrationCredential {
        guard let credentialIdentity = credentialRequest.credentialIdentity as? ASPasskeyCredentialIdentity else {
            throw LiquidAuthError.generalError()
        }
        
        do {
            try initializeExtension()
            guard let config = CoreAppConfiguration.shared, config.featureFlagService.isEnabled(.liquidAuthEnabled) else {
                throw LiquidAuthError.notImplemented()
            }
                   
            try await ensureAuthenticated()
            
            let response = try await createPassKey(credentialIdentity: credentialIdentity)
            let credential = try createRegistrationCredential(credentialIdentity: credentialIdentity, keyPair: response.keyPair,
                                                              clientDataHash: credentialRequest.clientDataHash, credentialId: response.credentialId)
            
            if let analytics = CoreAppConfiguration.shared?.analytics {
                analytics.track(.webAuthNPassKeyAdded())
            }
            return credential
        } catch let error as pera_wallet_core.LiquidAuthError {
            passKeyManager?.deletePassKeysForOriginAndUsername(origin: credentialIdentity.relyingPartyIdentifier,
                                                                    username: credentialIdentity.userName)
            throw error
        } catch {
            passKeyManager?.deletePassKeysForOriginAndUsername(origin: credentialIdentity.relyingPartyIdentifier,
                                                                    username: credentialIdentity.userName)
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    func handleAuthenticationRequest(_ requestParameters: ASPasskeyCredentialRequestParameters) async throws(pera_wallet_core.LiquidAuthError) -> ASPasskeyAssertionCredential {
        do {
            try initializeExtension()
            
            try await ensureAuthenticated()
            
            guard let passkey = passKeyManager?.allPassKeys.filter({$0.origin == requestParameters.relyingPartyIdentifier}).first else {
                throw LiquidAuthError.passKeyNotFound()
            }
            
            let credential = try await createAssertionCredential(requestParameters: requestParameters, passkey: passkey)
            
            if let analytics = CoreAppConfiguration.shared?.analytics {
                analytics.track(.webAuthNPassKeyUsed())
            }
            return credential
        } catch let error as pera_wallet_core.LiquidAuthError {
            throw error
        } catch {
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    private func initializeExtension() throws {
        CoreAppConfiguration.initialize()
        passKeyManager = try createPassKeyService()
    }
    
    private func createPassKey(credentialIdentity: ASPasskeyCredentialIdentity) async throws ->  PassKeyCreationResponse {
        let passKeyRequest = PassKeyCreationRequest(origin: credentialIdentity.relyingPartyIdentifier,
                                                    username: credentialIdentity.userName,
                                                    displayName: credentialIdentity.user,
                                                    address: nil)
        
        if passKeyManager?.findPassKeyForRequest(
            origin: credentialIdentity.relyingPartyIdentifier, username: credentialIdentity.userName) != nil {
            throw LiquidAuthError.passKeyExists()
        }
        
        guard let response = try await passKeyManager?.createAndSavePassKey(request: passKeyRequest) else {
            throw LiquidAuthError.generalError()
        }
        
        return response
    }
    
    private func createRegistrationCredential(credentialIdentity: ASPasskeyCredentialIdentity,
                                              keyPair: P256.Signing.PrivateKey,
                                              clientDataHash: Data,
                                              credentialId: Data) throws -> ASPasskeyRegistrationCredential {
        guard let rpData = credentialIdentity.relyingPartyIdentifier.data(using: .utf8) else {
            throw LiquidAuthError.generalError()
        }
        let credId = Data([UInt8](Utility.hashSHA256(keyPair.publicKey.rawRepresentation)))
        let rpIdHash = Utility.hashSHA256(rpData)
        let attestationObject = try liquidAuthSDK.makeAttestationObject(
            credentialId: credId, keyPair: keyPair, rpIdHash: rpIdHash)
        
        return ASPasskeyRegistrationCredential(
            relyingParty: credentialIdentity.relyingPartyIdentifier,
            clientDataHash: clientDataHash,
            credentialID: credentialId,
            attestationObject: attestationObject
        )
    }
    
    private func createAssertionCredential(requestParameters: ASPasskeyCredentialRequestParameters, passkey: PassKey) async throws -> ASPasskeyAssertionCredential {
        let origin = requestParameters.relyingPartyIdentifier
        let passKeyRequest = PassKeyAuthenticationRequest(
            origin: passkey.origin,
            username: passkey.username)
        guard let passkeyResponse = try await passKeyManager?.makeAuthenticationData(request: passKeyRequest) else {
            throw LiquidAuthError.passKeyNotFound()
        }
        
        guard let originData = origin.data(using: .utf8) else {
            throw LiquidAuthError.generalError()
        }
        let rpIdHash = Utility.hashSHA256(originData)
        let authenticatorData = liquidAuthSDK.makeAssertionObject(rpIdHash: rpIdHash, userPresent: true, userVerified: true,
                                                                      backupEligible: true, backupState: true, signCount: 0)
        
        let signature = try passkeyResponse.keyPair.signature(for: authenticatorData + requestParameters.clientDataHash)
        
        guard let usernameData = passkey.username.data(using: .utf8) else {
            throw LiquidAuthError.generalError()
        }
        
        let credId = Data([UInt8](Utility.hashSHA256(passkeyResponse.keyPair.publicKey.rawRepresentation)))
        return ASPasskeyAssertionCredential(
            userHandle: usernameData,
            relyingParty: requestParameters.relyingPartyIdentifier,
            signature: signature.derRepresentation,
            clientDataHash: requestParameters.clientDataHash,
            authenticatorData: authenticatorData,
            credentialID: credId
        )
    }
    
    private func createPassKeyService() throws -> PassKeyService {
        guard let hdWalletStorage = CoreAppConfiguration.shared?.hdWalletStorage,
              let session = CoreAppConfiguration.shared?.session else {
            throw LiquidAuthError.generalError()
        }
        return PassKeyService(hdWalletStorage: hdWalletStorage, session: session, liquidAuthSDK: liquidAuthSDK)
    }
    
    private func ensureAuthenticated() async throws {
        let isAuthenticated = await authenticateBiometrics()
        guard isAuthenticated else {
            throw LiquidAuthError.authenticationFailed()
        }
    }
    
    private func authenticateBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication // biometrics OR passcode

        if context.canEvaluatePolicy(policy, error: &error) {
            return await withCheckedContinuation { continuation in
                context.evaluatePolicy(policy, localizedReason: String(localized: "liquid-auth-authentication-required-prompt")) { success, _ in
                    continuation.resume(returning: success)
                }
            }
        } else {
            // Device does not support biometrics/passcode
            return false
        }
    }
}
