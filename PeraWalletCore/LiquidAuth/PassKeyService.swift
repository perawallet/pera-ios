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
import CryptoKit
import deterministicP256_swift
import SwiftCBOR
import x_hd_wallet_api

public protocol PassKeyServicing {
    func getSigningAddress() async throws -> HDWalletAddress?
    func getSigningWallet() async throws -> (HDWalletSDK, HDWalletAddressDetail)?
    func createAndSavePassKey(request: PassKeyCreationRequest) async throws -> PassKeyCreationResponse
    func getAuthenticationData(request: PassKeyAuthenticationRequest) async throws -> PassKeyAuthenticationResponse
    
    func findAllPassKeys() -> [PassKey]
    func deletePassKeysForOriginAndUsername(origin: String, username: String)
    func hasPassKey(origin: String, username: String) -> Bool
}

public final class PassKeyService: PassKeyServicing {
    static let AAGUID = UUID(uuidString: "418a66da-f981-47e8-814f-19c97f97bd4d")!
    
    let hdWalletStorage: HDWalletStorable
    let session: Session
    var signingAddress: HDWalletAddress?
    private let liquidAuthSDK: LiquidAuthSDKAPI
    
    public init(hdWalletStorage: HDWalletStorable,
                session: Session,
                liquidAuthSDK: LiquidAuthSDKAPI? = nil) {
        self.hdWalletStorage = hdWalletStorage
        self.session = session
        self.liquidAuthSDK = liquidAuthSDK ?? LiquidAuthSDKAPIImpl()
    }
}

public extension PassKeyService {
    
    static func isPassKeyURL(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "fido"
    }
    
    func getSigningAddress() async throws -> HDWalletAddress? {
        if let signingAddress = self.signingAddress {
            return signingAddress
        }
        
        guard let info = self.session.authenticatedUser?.accounts.first(where:{ $0.hdWalletAddressDetail != nil && $0.type == .standard }),
              let walletId = info.hdWalletAddressDetail?.walletId else {
            return nil
        }
        
        
        self.signingAddress = try self.hdWalletStorage.address(walletId: walletId, address: info.address)
        return self.signingAddress
    }
    
    func getSigningWallet() async throws -> (HDWalletSDK, HDWalletAddressDetail)? {
        // We're going to need access to the wallet seed for signing later
        
        guard let signingAddress = try await getSigningAddress(),
              let detail = self.session.authenticatedUser?.hdWalletsAccounts.first(where: { $0.address == signingAddress.address })?.hdWalletAddressDetail,
              let wallet = try hdWalletStorage.wallet(id: signingAddress.walletId),
              let seed = HDWalletUtils.generateSeed(fromEntropy: wallet.entropy),
              let sdk = HDWalletSDKImp(seed: seed.toHexString())
        else {
            return nil
        }
        
        return (sdk, detail)
    }
    
    func createAndSavePassKey(request: PassKeyCreationRequest) async throws -> PassKeyCreationResponse {
        let origin = request.origin
        
        guard let signingAddress = try await getSigningAddress() else {
            return PassKeyCreationResponse(error: "liquid-auth-no-account-found".localized())
        }
        
        let address = signingAddress.address
        let username = request.username ?? address
        
        if findPassKeyForRequest(origin: origin, username: username) != nil {
            return PassKeyCreationResponse(error: "liquid-auth-passkey-already-exists".localized())
        }
        
        let keyPair = try getDP256KeyPair(address: signingAddress, origin: request.origin, username: request.username ?? address)
        let credentialId = keyPair.publicKey.rawRepresentation.sha256()
        
        
        PassKey.create(entity: PassKey.entityName, with: [
            PassKey.DBKeys.username.rawValue: username,
            PassKey.DBKeys.displayName.rawValue: request.displayName,
            PassKey.DBKeys.origin.rawValue: request.origin,
            PassKey.DBKeys.credentialId.rawValue: credentialId.base64URLEncodedString(),
            PassKey.DBKeys.address.rawValue: signingAddress.address,
        ])
        
        return PassKeyCreationResponse(
            credentialId: credentialId,
            address: address,
            keyPair: keyPair
        )
    }
    
    func getAuthenticationData(request: PassKeyAuthenticationRequest) async throws -> PassKeyAuthenticationResponse {
        
        guard let signingAddress = try await getSigningAddress() else {
            return PassKeyAuthenticationResponse(error: "liquid-auth-no-account-found".localized())
        }
        
        let address = signingAddress.address
        let username = request.username ?? address
        
        guard let passkey = findPassKeyForRequest(origin: request.origin, username: username) else {
            return PassKeyAuthenticationResponse(error: "liquid-auth-no-passkey-found".localized())
        }
        
        let p256KeyPair = try getDP256KeyPair(address: signingAddress, origin: request.origin, username: username)
        let credentialId = Data([UInt8](p256KeyPair.publicKey.rawRepresentation.sha256()))
        
        if address != passkey.address || credentialId.base64URLEncodedString() != passkey.credentialId {
            return PassKeyAuthenticationResponse(error: "liquid-auth-invalid-passkey-found".localized())
        }
        
        passkey.update(entity: PassKey.entityName, with: [
            PassKey.DBKeys.lastUsed.rawValue: Date.now
        ])
        
        return PassKeyAuthenticationResponse(credentialId: passkey.credentialId,
                                             address: signingAddress, keyPair: p256KeyPair)
    }
    
    func hasPassKey(origin: String, username: String) -> Bool {
        findAllPassKeys().first(where: { $0.origin == origin && $0.username == username }) != nil
    }
    
    func deletePassKeysForOriginAndUsername(origin: String, username: String) {
        findAllPassKeys().filter({ $0.origin == origin && $0.username == username }).forEach {
            $0.remove(entity: PassKey.entityName)
        }
    }
    
    func findAllPassKeys() -> [PassKey] {
        let result = PassKey.fetchAllSyncronous(entity: PassKey.entityName)
        
        switch result {
        case .result(let object):
            if object is PassKey {
                let pk = object as! PassKey
                return [pk]
            }
            return []
        case .results(let objects):
            return objects.filter({$0 is PassKey}).map({ $0 as! PassKey })
        case .error:
            return []
        }
    }
    
    func findPassKeyForRequest(origin: String, username: String) -> PassKey? {
        let result = PassKey.fetchAllSyncronous(entity: PassKey.entityName)
        
        switch result {
        case .result(let object):
            if let pk = object as? PassKey, pk.origin == origin, pk.username == username {
                return pk
            }
        case .results(let objects):
            if let pk = objects.first(where: { $0 is PassKey && ($0 as? PassKey)?.origin == origin && ($0 as? PassKey)?.username == username }) as? PassKey {
                return pk
            }
        case .error: break
        }
        
        return nil
    }
    
    private func getDP256KeyPair(address: HDWalletAddress, origin: String, username: String) throws -> P256.Signing.PrivateKey {
        let mnemonics = PassphraseUtils.mnemonics(address: address, hdWalletStorage: self.hdWalletStorage, session: self.session)
        let dp256 = DeterministicP256()
        let derivedMainKey = try dp256.genDerivedMainKeyWithBIP39(phrase: mnemonics.mnemonics.joined(separator: " "))
        let p256KeyPair = dp256.genDomainSpecificKeyPair(derivedMainKey: derivedMainKey, origin: origin, userHandle: username)
        return p256KeyPair
    }
}
