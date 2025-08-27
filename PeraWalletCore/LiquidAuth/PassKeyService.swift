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
import CryptoKit
import deterministicP256_swift
import SwiftCBOR
import x_hd_wallet_api

public protocol PassKeyServicing {
    var allPassKeys: [PassKey] { get }
    
    func findAllSigningAccounts() async throws(LiquidAuthError) -> [AccountInformation]
    func makeSigningSDK(account: AccountInformation) async throws(LiquidAuthError) -> HDWalletSDK?
    func createAndSavePassKey(request: PassKeyCreationRequest) async throws(LiquidAuthError) -> PassKeyCreationResponse
    func makeAuthenticationData(request: PassKeyAuthenticationRequest) async throws(LiquidAuthError) -> PassKeyAuthenticationResponse
    
    func deletePassKeysForOriginAndUsername(origin: String, username: String)
    func hasPassKey(origin: String, username: String) -> Bool
}

public final class PassKeyService: PassKeyServicing {
    static let AAGUID = UUID(uuidString: "418a66da-f981-47e8-814f-19c97f97bd4d")!
    static let FIDO_SCHEME = "fido"
    
    let hdWalletStorage: HDWalletStorable
    let session: Session
    var signingAccounts: [AccountInformation]? = nil
    private let liquidAuthSDK: LiquidAuthSDKAPI
    
    public init(hdWalletStorage: HDWalletStorable,
                session: Session,
                liquidAuthSDK: LiquidAuthSDKAPI = LiquidAuthSDKAPIImpl()) {
        self.hdWalletStorage = hdWalletStorage
        self.session = session
        self.liquidAuthSDK = liquidAuthSDK
    }
}

public extension PassKeyService {
    
    var allPassKeys: [PassKey] {
        let result = PassKey.fetchAllSyncronous(entity: PassKey.entityName)
        
        switch result {
        case .result(let object):
            if object is PassKey {
                return [object as! PassKey]
            }
            return []
        case .results(let objects):
            return objects.filter({$0 is PassKey}).map { $0 as! PassKey }
        case .error:
            return []
        }
    }
    
    static func isPassKeyURL(_ url: URL) -> Bool {
        url.scheme?.lowercased() == PassKeyService.FIDO_SCHEME
    }
    
    func findAllSigningAccounts() async throws(LiquidAuthError) -> [AccountInformation] {
        if let signingAccounts {
            return signingAccounts
        }
        
        signingAccounts = session.authenticatedUser?.accounts.filter { $0.hdWalletAddressDetail != nil && $0.type == .standard }
        return signingAccounts ?? []
    }
    
    func makeSigningSDK(account: AccountInformation) async throws(LiquidAuthError) -> HDWalletSDK? {
        do {
            guard let walletId = account.hdWalletAddressDetail?.walletId,
                  let wallet = try hdWalletStorage.wallet(id: walletId),
                  let seed = HDWalletUtils.generateSeed(fromEntropy: wallet.entropy),
                  let sdk = HDWalletSDKImp(seed: seed.toHexString())
            else {
                return nil
            }
            
            return sdk
        } catch {
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    func createAndSavePassKey(request: PassKeyCreationRequest) async throws(LiquidAuthError) -> PassKeyCreationResponse {
        let origin = request.origin
        let signingAccounts = try await findAllSigningAccounts()
        guard let signingAccount = signingAccounts.first(where: { request.address == nil || $0.address == request.address }) else {
            throw LiquidAuthError.signingAccountNotFound()
        }
        
        if findPassKeyForRequest(origin: origin, username: request.username) != nil {
            throw LiquidAuthError.passKeyExists()
        }
        
        do {
            let keyPair = try dp256KeyPair(info: signingAccount, origin: request.origin, username: request.username)
            let credentialId = keyPair.publicKey.rawRepresentation.sha256()
            
            
            PassKey.create(entity: PassKey.entityName, with: [
                PassKey.DBKeys.username.rawValue: request.username,
                PassKey.DBKeys.displayName.rawValue: request.displayName,
                PassKey.DBKeys.origin.rawValue: request.origin,
                PassKey.DBKeys.credentialId.rawValue: credentialId.base64URLEncodedString(),
                PassKey.DBKeys.address.rawValue: signingAccount.address,
            ])
            
            return PassKeyCreationResponse(
                credentialId: credentialId,
                address: signingAccount.address,
                keyPair: keyPair
            )
        } catch {
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    func makeAuthenticationData(request: PassKeyAuthenticationRequest) async throws(LiquidAuthError) -> PassKeyAuthenticationResponse {
        guard let passkey = findPassKeyForRequest(origin: request.origin, username: request.username) else {
            throw LiquidAuthError.passKeyNotFound()
        }
        let signingAccounts = try await findAllSigningAccounts()
        guard let signingAccount = signingAccounts.first(where: { passkey.address == $0.address }) else {
            throw LiquidAuthError.signingAccountNotFound()
        }
        
        do {
            let p256KeyPair = try dp256KeyPair(info: signingAccount, origin: request.origin, username: request.username)
            let credentialId = Data([UInt8](p256KeyPair.publicKey.rawRepresentation.sha256()))
            
            if signingAccount.address != passkey.address || credentialId.base64URLEncodedString() != passkey.credentialId {
                throw LiquidAuthError.passKeyInvalid()
            }
            
            passkey.update(entity: PassKey.entityName, with: [
                PassKey.DBKeys.lastUsed.rawValue: Date.now
            ])
            
            return PassKeyAuthenticationResponse(credentialId: passkey.credentialId,
                                                 address: signingAccount.address, keyPair: p256KeyPair)
        } catch let error as LiquidAuthError {
            throw error
        } catch {
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    func hasPassKey(origin: String, username: String) -> Bool {
        allPassKeys.first(where: { $0.origin == origin && $0.username == username }) != nil
    }
    
    func deletePassKeysForOriginAndUsername(origin: String, username: String) {
        allPassKeys.filter({ $0.origin == origin && $0.username == username }).forEach {
            $0.remove(entity: PassKey.entityName)
        }
    }
    
    func findPassKeyForRequest(origin: String, username: String) -> PassKey? {
        let result = PassKey.fetchAllSyncronous(entity: PassKey.entityName)
        
        switch result {
        case .result(let object):
            if let passkey = object as? PassKey, passkey.origin == origin, passkey.username == username {
                return passkey
            }
        case .results(let objects):
            if let passkey = objects.first(where: { $0 is PassKey && ($0 as? PassKey)?.origin == origin && ($0 as? PassKey)?.username == username }) as? PassKey {
                return passkey
            }
        case .error: break
        }
        
        return nil
    }
    
    private func dp256KeyPair(info: AccountInformation, origin: String, username: String) throws -> P256.Signing.PrivateKey {
        let mnemonics = PassphraseUtils.mnemonics(info: info, hdWalletStorage: hdWalletStorage, session: session)
        let dp256 = DeterministicP256()
        let derivedMainKey = try dp256.genDerivedMainKeyWithBIP39(phrase: mnemonics.mnemonics.joined(separator: " "))
        let p256KeyPair = dp256.genDomainSpecificKeyPair(derivedMainKey: derivedMainKey, origin: origin, userHandle: username)
        return p256KeyPair
    }
}
