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
import AVFoundation
import LocalAuthentication
import x_hd_wallet_api
import WebRTC

public protocol LiquidAuthServicing {
    func handleAuthRequest(request: LiquidAuthRequest) async -> LiquidAuthResponse
    func startSignaling(
        origin: String,
        requestId: String,
        messageHandler: @escaping (String) -> Void
    ) async throws
}

public final class LiquidAuthService: LiquidAuthServicing {
    private static let LIQUID_AUTH_SCHEME = "liquid"
    private static let LIQUID_AUTH_REQUEST_ID = "requestId"
    private let featureFlagService: FeatureFlagServicing
    private let passKeyService: PassKeyServicing
    private let liquidAuthSDK: LiquidAuthSDKAPI
    
    public init(
        passKeyService: PassKeyServicing,
        featureFlagService: FeatureFlagServicing,
        liquidAuthSDK: LiquidAuthSDKAPI? = nil
    ) {
        self.passKeyService = passKeyService
        self.featureFlagService = featureFlagService
        self.liquidAuthSDK = liquidAuthSDK ?? LiquidAuthSDKAPIImpl()
    }
}

public extension LiquidAuthService {
    
    func handleAuthRequest(request: LiquidAuthRequest) async -> LiquidAuthResponse {
        guard self.featureFlagService.isEnabled(.liquidAuthEnabled) else {
            return cleanUpAndReturnError(origin: nil, username: nil, error: "liquid-auth-not-implemented")
        }
        
        do {
            guard let signingAddress = try await self.passKeyService.getSigningAddress() else {
                return cleanUpAndReturnError(origin: nil, username: nil, error: "liquid-auth-no-account-found")
            }
            
            if self.passKeyService.hasPassKey(origin: request.origin, username: signingAddress.address) {
                return await authenticate(request: request)
            } else {
                return await register(request: request)
            }
        } catch {
            return cleanUpAndReturnError(origin: nil, username: nil, error: error.localizedDescription)
        }
    }
    
    func startSignaling(
        origin: String,
        requestId: String,
        messageHandler: @escaping (String) -> Void
    ) async throws {
        if !self.featureFlagService.isEnabled(.liquidAuthEnabled) {
            throw NSError(domain: "LiquidAuth not enabled", code: -1, userInfo: nil)
        }
        self.liquidAuthSDK.signalService.start(url: origin, httpClient: URLSession.shared)

        //TODO: we will need to either inject a username/password here or host our own TURN server or find a free one
        let NODELY_TURN_USERNAME = ""
        let NODELY_TURN_CREDENTIAL = ""

        let iceServers = [
            RTCIceServer(
                urlStrings: [
                    "stun:stun.l.google.com:19302",
                    "stun:stun1.l.google.com:19302",
                    "stun:stun2.l.google.com:19302",
                    "stun:stun3.l.google.com:19302",
                    "stun:stun4.l.google.com:19302",
                ]
            ),
            RTCIceServer(
                urlStrings: [
                    "turn:global.turn.nodely.network:80?transport=tcp",
                    "turns:global.turn.nodely.network:443?transport=tcp",
                    "turn:eu.turn.nodely.io:80?transport=tcp",
                    "turns:eu.turn.nodely.io:443?transport=tcp",
                    "turn:us.turn.nodely.io:80?transport=tcp",
                    "turns:us.turn.nodely.io:443?transport=tcp",
                ],
                username: NODELY_TURN_USERNAME,
                credential: NODELY_TURN_CREDENTIAL
            ),
        ]

        self.liquidAuthSDK.signalService.connectToPeer(
            requestId: requestId,
            type: "answer",
            origin: origin,
            iceServers: iceServers,
            onMessage: messageHandler,
            onStateChange: { [weak self] state in
                if state == "open" {
                    self?.liquidAuthSDK.signalService.sendMessage("ping")
                }
            }
        )
    }
    
    static func getRequestForURL(_ url: URL) -> LiquidAuthRequest? {
        guard url.scheme == LIQUID_AUTH_SCHEME,
              let host = url.host,
              let queryItems = url.queryParameters,
              let requestId = queryItems.first(where: { $0.key == LIQUID_AUTH_REQUEST_ID })?.value
        else {
            return nil
        }
        return LiquidAuthRequest(origin: host, requestId: requestId)
    }

    private func register(request: LiquidAuthRequest) async -> LiquidAuthResponse {
        var passKeyAddress: String? = nil
        do {            
            let passKeyRequest = PassKeyCreationRequest(origin: request.origin, displayName: "Liquid Auth Passkey")
            let response = try await self.passKeyService.createAndSavePassKey(request: passKeyRequest)
            
            guard let credentialId = response.credentialId, response.success,
                  let address = response.address,
                  let keyPair = response.keyPair else {
                return cleanUpAndReturnError(origin: request.origin, username: response.address)
            }
            passKeyAddress = address
            
            let data = try await self.liquidAuthSDK.postAttestationOptions(origin: request.origin, username: address)

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let challengeBase64Url = json["challenge"] as? String,
                  let rpId = extractRpId(json: json),
                  let rpIdHash = rpId.data(using: .utf8)?.sha256()
            else {
                return cleanUpAndReturnError(origin: request.origin, username: address)
            }
            
            guard let decodedChallenge = self.liquidAuthSDK.decodeBase64Url(challengeBase64Url),
                  let clientDataJSON = try buildClientData(type: "webauthn.create", challengeUrl: challengeBase64Url, rpId: rpId),
                  let signature = try await signChallenge(challenge: Data([UInt8](decodedChallenge)))
            else {
                return cleanUpAndReturnError(origin: request.origin, username: address)
            }
            
            let attestationObject = try self.liquidAuthSDK.getAttestationObject(credentialId: credentialId, keyPair: keyPair, rpIdHash: rpIdHash)
            let credential = getCredentialObject(credentialId: credentialId,
                                                 clientDataJSON: clientDataJSON,
                                                 attestationObject: attestationObject)
            
            let device = await UIDevice.current.model
            let responseData = try await self.liquidAuthSDK.postAttestationResult(origin: request.origin, credential: credential, liquidExt: [
                "type": "algorand",
                "requestId": request.requestId,
                "address": address,
                "signature": signature.base64URLEncodedString(),
                "device": device
            ])

            if let responseJSON = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let errorReason = responseJSON["error"] as? String
            {
                return cleanUpAndReturnError(origin: request.origin, username: response.address, error: errorReason)
            } else {
                return LiquidAuthResponse(credentialId: credentialId.base64URLEncodedString())
            }
        } catch {
            return cleanUpAndReturnError(origin: request.origin, username: passKeyAddress, error: error.localizedDescription)
        }
    }

    private func authenticate(request: LiquidAuthRequest) async -> LiquidAuthResponse {
        do {
            let passKeyRequest = PassKeyAuthenticationRequest(origin: request.origin)
            let passKeyResponse = try await self.passKeyService.getAuthenticationData(request: passKeyRequest)
            
            let response = try await doAuthenticate(request: request, passKeyResponse: passKeyResponse)
            return response
        } catch {
            return LiquidAuthResponse(error: error.localizedDescription)
        }
    }
    
    private func doAuthenticate(
        request: LiquidAuthRequest,
        passKeyResponse: PassKeyAuthenticationResponse
    ) async throws -> LiquidAuthResponse {
        
        guard let credentialId = passKeyResponse.credentialId,
              let address = passKeyResponse.address?.address,
                passKeyResponse.success else {
            return LiquidAuthResponse(error: passKeyResponse.error)
        }
        
        let device = await UIDevice.current.model
        
        let data = try await self.liquidAuthSDK.postAssertionOptions(origin: request.origin, credentialId: credentialId)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let challengeBase64Url = json["challenge"] as? String,
              let rp = extractRpId(json: json),
              let rpIdHash = rp.data(using: .utf8)?.sha256(),
              let challengeData = self.liquidAuthSDK.decodeBase64Url(challengeBase64Url)
        else {
            return LiquidAuthResponse(error: "liquid-auth-error".localized())
        }
        
        let challengeBytes = Data([UInt8](challengeData))
        
        guard let signature = try await signChallenge(challenge: challengeBytes),
              let clientDataJSON = try buildClientData(type: "webauthn.get", challengeUrl: challengeBase64Url, rpId: rp) else {
            return LiquidAuthResponse(error: "liquid-auth-error".localized())
        }
        
        let authenticatorData = self.liquidAuthSDK.getAssertionObject(rpIdHash: rpIdHash, userPresent: true, userVerified: true,
                                                                      backupEligible: false, backupState: false, signCount: 0)
        let clientDataHash = clientDataJSON.sha256()
        let dataToSign = authenticatorData + clientDataHash
        
        guard let keyPair = passKeyResponse.keyPair else {
            return LiquidAuthResponse(error: "liquid-auth-error".localized())
        }
        
        let p256Signature = try keyPair.signature(for: dataToSign)

        let assertionResponse: [String: Any] = [
            "id": credentialId,
            "type": "public-key",
            "userHandle": address,
            "rawId": credentialId,
            "response": [
                "clientDataJSON": clientDataJSON.base64URLEncodedString(),
                "authenticatorData": authenticatorData.base64URLEncodedString(),
                "signature": p256Signature.derRepresentation.base64URLEncodedString(),
            ],
        ]

        // Serialize the assertion response into a JSON string
        guard let assertionResponseData = try? JSONSerialization.data(withJSONObject: assertionResponse, options: []),
              let assertionResponseJSON = String(data: assertionResponseData, encoding: .utf8)
        else {
            return LiquidAuthResponse(error: "liquid-auth-error".localized())
        }
        
        // Post the assertion result
        let responseData = try await self.liquidAuthSDK.postAssertionResult(
            origin: request.origin,
            credential: assertionResponseJSON,
            liquidExt: [
                "type": "algorand",
                "requestId": request.requestId,
                "address": address,
                "signature": signature.base64URLEncodedString(),
                "device": device,
            ]
        )

        // Parse the response to check for errors
        if let responseJSON = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
            let errorReason = responseJSON["error"] as? String
        {
            return LiquidAuthResponse(error: errorReason)
        } else {
            return LiquidAuthResponse(credentialId: credentialId)
        }
    }
    
    private func getCredentialObject(credentialId: Data, clientDataJSON: Data, attestationObject: Data) -> [String: Any] {
        [
           "id": credentialId.base64URLEncodedString(),
           "type": "public-key",
           "rawId": credentialId.base64URLEncodedString(),
           "response": [
               "clientDataJSON": clientDataJSON.base64URLEncodedString(),
               "attestationObject": attestationObject.base64URLEncodedString(),
           ],
       ]
    }
    
    private func extractRpId(json: [String: Any]?) -> String? {
        guard let jsonObject = json else {
            return nil
        }
        // there are two different supported json structures we need to handle
        if let rp = jsonObject["rp"] as? [String: Any], let id = rp["id"] as? String {
            return id
        } else if let id = jsonObject["rpId"] as? String {
            return id
        } else {
            return nil
        }
    }
    
    private func buildClientData(type: String, challengeUrl: String, rpId: String) throws  -> Data? {
        let data: [String: Any] = [
            "type": type,
            "challenge": challengeUrl,
            "origin": "https://\(rpId)",
        ]
        return try? JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    private func signChallenge(challenge: Data) async throws -> Data? {
        guard let schemaPath = Bundle.main.path(forResource: "auth.request", ofType: "json"),
              let (sdk, detail) = try await self.passKeyService.getSigningWallet() else {
            return nil
        }
        
        //if we have valid json we can validate it
        if let challengeString = String(data: challenge, encoding: .utf8),
           let decodedJSON = self.liquidAuthSDK.decodeBase64UrlToJSON(challengeString) {
            let schema = try Schema(filePath: schemaPath)
            
            let valid = try sdk.validateData(
                Data(decodedJSON.utf8),
                against: SignMetadata(encoding: Encoding.none, schema: schema)
            )
            
            if !valid {
                return nil
            }
        }
        
        let draft = HDWalletSignDataDraft(
            context: .address,
            account: detail.account,
            change: detail.change,
            keyIndex: detail.keyIndex,
            data: challenge,
            metadata: DataSigningMetadata(encoding: .none, schema: schemaPath),
            derivationType: detail.derivationType
        )
        return try sdk.rawSign(draft)
    }
    
    private func cleanUpAndReturnError(origin: String?, username: String?, error: String? = nil) -> LiquidAuthResponse {
        if let username = username, let origin = origin {
            self.passKeyService.deletePassKeysForOriginAndUsername(origin: origin, username: username)
        }
        return LiquidAuthResponse(error: error ?? "liquid-auth-error".localized())
    }
}
