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

import AuthenticationServices
import LocalAuthentication
import Firebase
import SwiftCBOR
import UIKit
import CoreData
import pera_wallet_core
import LiquidAuthSDK
import SwiftUI
@available(iOS 17, *)
class CredentialProviderService {
    private let liquidAuthSDK: LiquidAuthSDKAPI = LiquidAuthSDKAPIImpl()
    private let extensionDelegate = AppInitializer()
    private var passKeyManager: PassKeyService?
    
    func handleRegistrationRequest(_ credentialRequest: ASPasskeyCredentialRequest) async -> Result<ASPasskeyRegistrationCredential, String> {
        guard let credentialIdentity = credentialRequest.credentialIdentity as? ASPasskeyCredentialIdentity,
              let rpData = credentialIdentity.relyingPartyIdentifier.data(using: .utf8) else {
            
            return .failure("liquid-auth-error".localized())
        }
        
        do {
            self.initializeExtension()
            guard let _ = CoreAppConfiguration.shared?.featureFlagService.isEnabled(.liquidAuthEnabled) else {
                return .failure("liquid-auth-not-implemented".localized())
            }
                    
            
            let authenticated = await authenticateBiometrics()
            guard authenticated else {
                return .failure("local-authentication-failed".localized())
            }
            
            let passKeyRequest = PassKeyCreationRequest(origin: credentialIdentity.relyingPartyIdentifier,
                                                        displayName: credentialIdentity.user,
                                                        username: credentialIdentity.userName)
            
            if self.passKeyManager?.findPassKeyForRequest(
                origin: credentialIdentity.relyingPartyIdentifier, username: credentialIdentity.userName) != nil {
                return .failure("liquid-auth-passkey-already-exists".localized())
            }
            
            guard let response = try await self.passKeyManager?.createAndSavePassKey(request: passKeyRequest) else {
                self.passKeyManager?.deletePassKeysForOriginAndUsername(origin: credentialIdentity.relyingPartyIdentifier, username: credentialIdentity.userName)
                return .failure("liquid-auth-error".localized())
            }
            
            if response.error != nil {
                self.passKeyManager?.deletePassKeysForOriginAndUsername(origin: credentialIdentity.relyingPartyIdentifier,
                                                                        username: credentialIdentity.userName)
                return .failure("liquid-auth-error".localized())
            }
            
            guard let credentialId = response.credentialId,
                  let keyPair = response.keyPair else {
                self.passKeyManager?.deletePassKeysForOriginAndUsername(origin: credentialIdentity.relyingPartyIdentifier,
                                                                        username: credentialIdentity.userName)
                return .failure("liquid-auth-error".localized())
                
            }
            let credId = Data([UInt8](Utility.hashSHA256(keyPair.publicKey.rawRepresentation)))
            let rpIdHash = Utility.hashSHA256(rpData)
            let attestationObject = try self.liquidAuthSDK.getAttestationObject(
                credentialId: credId, keyPair: keyPair, rpIdHash: rpIdHash)
            
            let credential = ASPasskeyRegistrationCredential(
                relyingParty: credentialIdentity.relyingPartyIdentifier,
                clientDataHash:  credentialRequest.clientDataHash,
                credentialID: credentialId,
                attestationObject: attestationObject
            )
            return .success(credential)
        } catch {
            self.passKeyManager?.deletePassKeysForOriginAndUsername(origin: credentialIdentity.relyingPartyIdentifier,
                                                                    username: credentialIdentity.userName)
            return .failure("liquid-auth-error".localized())
        }
    }
    
    func handleAuthenticationRequest(_ requestParameters: ASPasskeyCredentialRequestParameters) async -> Result<ASPasskeyAssertionCredential, String> {
        do {
            self.initializeExtension()
            
            let authenticated = await authenticateBiometrics()
            guard authenticated else {
                return .failure("local-authentication-failed".localized())
            }
            
            guard let passkey = self.passKeyManager?.findAllPassKeys().filter({$0.origin == requestParameters.relyingPartyIdentifier}).first else {
                return .failure("liquid-auth-no-passkey-found".localized())
            }
            
            let origin = requestParameters.relyingPartyIdentifier
            let passKeyRequest = PassKeyAuthenticationRequest(
                origin: passkey.origin,
                username: passkey.username)
            guard let passkeyResponse = try await self.passKeyManager?.getAuthenticationData(request: passKeyRequest) else {
                return .failure("liquid-auth-no-passkey-found".localized())
            }
            
            guard let keyPair = passkeyResponse.keyPair, passkeyResponse.success else {
                return .failure(passkeyResponse.error?.localized() ?? "liquid-auth-error".localized())
            }
            
            guard let originData = origin.data(using: .utf8) else {
                return .failure("liquid-auth-error".localized())
            }
            let rpIdHash = Utility.hashSHA256(originData)
            let authenticatorData = self.liquidAuthSDK.getAssertionObject(rpIdHash: rpIdHash, userPresent: true, userVerified: true,
                                                                          backupEligible: true, backupState: true, signCount: 0)
            
            let signature = try keyPair.signature(for: authenticatorData + requestParameters.clientDataHash)
            
            guard let usernameData = passkey.username.data(using: .utf8) else {
                return .failure("liquid-auth-error".localized())
            }
            
            let credId = Data([UInt8](Utility.hashSHA256(keyPair.publicKey.rawRepresentation)))
            let credential = ASPasskeyAssertionCredential(
                userHandle: usernameData,
                relyingParty: requestParameters.relyingPartyIdentifier,
                signature: signature.derRepresentation,
                clientDataHash: requestParameters.clientDataHash,
                authenticatorData: authenticatorData,
                credentialID: credId
            )
            return .success(credential)
        } catch {
            return .failure("\(error.localizedDescription)")
        }
    }
    
    private func initializeExtension() {
        self.extensionDelegate.initialize()
        self.passKeyManager = createPassKeyService()
    }
    
    private func createPassKeyService() -> PassKeyService {
        guard let hdWalletStorage = CoreAppConfiguration.shared?.hdWalletStorage,
              let session = CoreAppConfiguration.shared?.session else {
            fatalError("An error occured while initializing the passkey service")
        }
        return PassKeyService(hdWalletStorage: hdWalletStorage, session: session, liquidAuthSDK: liquidAuthSDK)
    }
    
    func authenticateBiometrics(reason: String = "Authenticate to access your credentials") async -> Bool {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication // biometrics OR passcode

        if context.canEvaluatePolicy(policy, error: &error) {
            return await withCheckedContinuation { continuation in
                context.evaluatePolicy(policy, localizedReason: reason) { success, _ in
                    continuation.resume(returning: success)
                }
            }
        } else {
            // Device does not support biometrics/passcode
            return false
        }
    }
}
