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
import AVFoundation
import LocalAuthentication
import x_hd_wallet_api
import WebRTC

public protocol LiquidAuthServicing {
    func handleAuthRequest(request: LiquidAuthRequest) async throws(LiquidAuthError) -> LiquidAuthResponse
    func startSignaling(
        origin: String,
        requestId: String,
        messageHandler: @escaping (String) -> Void
    ) async throws(LiquidAuthError)
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
        liquidAuthSDK: LiquidAuthSDKAPI = LiquidAuthSDKAPIImpl()
    ) {
        self.passKeyService = passKeyService
        self.featureFlagService = featureFlagService
        self.liquidAuthSDK = liquidAuthSDK
    }
}

public extension LiquidAuthService {
    
    func handleAuthRequest(request: LiquidAuthRequest) async throws(LiquidAuthError) -> LiquidAuthResponse {
        guard featureFlagService.isEnabled(.liquidAuthEnabled) else {
            throw LiquidAuthError.notImplemented()
        }
        
        guard let signingAccount = try await passKeyService.findAllSigningAccounts().first else {
            throw LiquidAuthError.signingAccountNotFound()
        }
        
        if passKeyService.hasPassKey(origin: request.origin, username: signingAccount.address) {
            return try await authenticate(signingAccount: signingAccount, request: request)
        } else {
            return try await register(signingAccount: signingAccount, request: request)
        }
    }
    
    func startSignaling(
        origin: String,
        requestId: String,
        messageHandler: @escaping (String) -> Void
    ) async throws(LiquidAuthError) {
        if !featureFlagService.isEnabled(.liquidAuthEnabled) {
            throw LiquidAuthError.notImplemented()
        }
        liquidAuthSDK.signalService.start(url: origin, httpClient: URLSession.shared)

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

        liquidAuthSDK.signalService.connectToPeer(
            requestId: requestId,
            type: SignalType.answer.rawValue,
            origin: origin,
            iceServers: iceServers,
            onMessage: messageHandler,
            onStateChange: { [weak self] state in
                if state == "open" {
                    //TODO: this is a temporary initiation.  we will need to implement a more complete liquid auth protocol handler
                    self?.liquidAuthSDK.signalService.sendMessage("ping")
                }
            }
        )
    }
    
    static func makeRequestForURL(_ url: URL) -> LiquidAuthRequest? {
        guard url.scheme == LIQUID_AUTH_SCHEME,
              let host = url.host,
              let queryItems = url.queryParameters,
              let requestId = queryItems.first(where: { $0.key == LIQUID_AUTH_REQUEST_ID })?.value
        else {
            return nil
        }
        return LiquidAuthRequest(origin: host, requestId: requestId)
    }

    private func register(signingAccount: AccountInformation, request: LiquidAuthRequest) async throws(LiquidAuthError)  -> LiquidAuthResponse {
        do {
            let passKeyRequest = PassKeyCreationRequest(origin: request.origin, username: signingAccount.address, displayName: "Liquid Auth Passkey", address: nil)
            let response = try await passKeyService.createAndSavePassKey(request: passKeyRequest)
            return try await signRegistrationChallenge(signingAccount: signingAccount, passKeyResponse: response, request: request)
        } catch let error as LiquidAuthError {
            throw error
        } catch {
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    private func authenticate(signingAccount: AccountInformation, request: LiquidAuthRequest) async throws(LiquidAuthError) -> LiquidAuthResponse {
        do {
            let passKeyRequest = PassKeyAuthenticationRequest(origin: request.origin, username: signingAccount.address)
            let passKeyResponse = try await passKeyService.makeAuthenticationData(request: passKeyRequest)
            
            let response = try await signAuthenticationChallenge(signingAccount: signingAccount, request: request, passKeyResponse: passKeyResponse)
            return response
        } catch let error as LiquidAuthError {
            throw error
        } catch {
            throw LiquidAuthError.generalError(cause: error)
        }
    }
    
    private func signRegistrationChallenge(signingAccount: AccountInformation, passKeyResponse response: PassKeyCreationResponse, request: LiquidAuthRequest) async throws -> LiquidAuthResponse {
        
        let optionsData = try await postAttestationOptions(origin: request.origin, address: response.address)
        
        guard let decodedChallenge = liquidAuthSDK.decodedBase64Url(optionsData.challengeUrl),
              let clientDataJSON = try clientData(type: "webauthn.create", challengeUrl: optionsData.challengeUrl, relyingParty: optionsData.relyingPartyId),
              let signature = try await signChallenge(signingAccount: signingAccount, challenge: Data([UInt8](decodedChallenge)))
        else {
            passKeyService.deletePassKeysForOriginAndUsername(origin: request.origin, username: response.address)
            throw LiquidAuthError.generalError()
        }
        
        let attestationObject = try liquidAuthSDK.makeAttestationObject(credentialId: response.credentialId,
                                                                        keyPair: response.keyPair,
                                                                        rpIdHash: optionsData.relyingPartyIdHash)
        let credential = makeCredentialObject(credentialId: response.credentialId,
                                             clientDataJSON: clientDataJSON,
                                             attestationObject: attestationObject)
        
        return try await postAttestationResults(request: request, response: response, signature: signature, credential: credential)
    }
    
    private func signAuthenticationChallenge(
        signingAccount: AccountInformation,
        request: LiquidAuthRequest,
        passKeyResponse: PassKeyAuthenticationResponse
    ) async throws -> LiquidAuthResponse {
        let optionsData = try await postAssertionOptions(origin: request.origin, credentialId: passKeyResponse.credentialId)
        
        guard let challengeData = liquidAuthSDK.decodedBase64Url(optionsData.challengeUrl) else {
            throw LiquidAuthError.generalError()
        }
        let challengeBytes = Data([UInt8](challengeData))
        
        guard let signature = try await signChallenge(signingAccount: signingAccount, challenge: challengeBytes),
              let clientDataJSON = try clientData(type: "webauthn.get", challengeUrl: optionsData.challengeUrl, relyingParty: optionsData.relyingPartyId) else {
            throw LiquidAuthError.generalError()
        }
        
        let assertionResponse = try makeAssertionResponse(clientData: clientDataJSON, passKeyResponse: passKeyResponse, optionsData: optionsData)
        
        try await postAssertionResult(request: request, credential: assertionResponse, signature: signature, address: passKeyResponse.address)
        return LiquidAuthResponse(credentialId: passKeyResponse.credentialId)
    }
    
    
    
    private func postAssertionOptions(origin: String, credentialId: String) async throws -> PostOptionsResult {
        let data = try await liquidAuthSDK.postAssertionOptions(origin: origin, credentialId: credentialId)
        guard let response = try? JSONDecoder().decode(AssertionOptionsResponseJson.self, from: data),
              let challengeBase64Url = response.challenge,
              let relyingPartyId = response.rp?.id ?? response.rpId,
              let relyingPartyIdHash = relyingPartyId.data(using: .utf8)?.sha256()
        else {
            throw LiquidAuthError.generalError()
        }
        
        return PostOptionsResult(challengeUrl: challengeBase64Url, relyingPartyId: relyingPartyId, relyingPartyIdHash: relyingPartyIdHash)
    }
    
    private func postAssertionResult(request: LiquidAuthRequest, credential: String, signature: Data, address: String) async throws {
        let device = await UIDevice.current.model
        
        // Post the assertion result
        let responseData = try await liquidAuthSDK.postAssertionResult(
            origin: request.origin,
            credential: credential,
            liquidExtension: [
                "type": "algorand",
                "requestId": request.requestId,
                "address": address,
                "signature": signature.base64URLEncodedString(),
                "device": device,
            ]
        )

        // Parse the response to check for errors
        if let responseJSON = try? JSONDecoder().decode(ResponseJsonWithError.self, from: responseData), responseJSON.error != nil {
            throw LiquidAuthError.generalError()
        }
    }
    
    private func makeAssertionResponse(clientData: Data, passKeyResponse: PassKeyAuthenticationResponse, optionsData: PostOptionsResult) throws -> String {
        let authenticatorData = liquidAuthSDK.makeAssertionObject(rpIdHash: optionsData.relyingPartyIdHash, userPresent: true, userVerified: true,
                                                                      backupEligible: false, backupState: false, signCount: 0)
        
        let clientDataHash = clientData.sha256()
        let dataToSign = authenticatorData + clientDataHash
        
        let p256Signature = try passKeyResponse.keyPair.signature(for: dataToSign)

        let assertionResponse = AssertionPayload(
            credentialId: passKeyResponse.credentialId,
            address: passKeyResponse.address,
            clientData: clientData,
            authenticatorData: authenticatorData,
            p256SignatureDer: p256Signature.derRepresentation)

        // Serialize the assertion response into a JSON string
        guard let assertionResponseData = try? JSONEncoder().encode(assertionResponse),
              let assertionResponseJSON = String(data: assertionResponseData, encoding: .utf8)
        else {
            throw LiquidAuthError.generalError()
        }
        
        return assertionResponseJSON
    }
    
    private func postAttestationOptions(origin: String, address: String) async throws -> PostOptionsResult {
        let data = try await liquidAuthSDK.postAttestationOptions(origin: origin, username: address)

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let challengeBase64Url = json["challenge"] as? String,
              let relyingPartyId = extractRelyingPartyId(json: json),
              let relyingPartyIdHash = relyingPartyId.data(using: .utf8)?.sha256()
        else {
            passKeyService.deletePassKeysForOriginAndUsername(origin: origin, username: address)
            throw LiquidAuthError.generalError()
        }
        
        return PostOptionsResult(challengeUrl: challengeBase64Url, relyingPartyId: relyingPartyId, relyingPartyIdHash: relyingPartyIdHash)
    }
    
    private func postAttestationResults(request: LiquidAuthRequest, response: PassKeyCreationResponse, signature: Data, credential: [String: Any]) async throws -> LiquidAuthResponse {
        let device = await UIDevice.current.model
        let responseData = try await liquidAuthSDK.postAttestationResult(origin: request.origin, credential: credential, liquidExtension: [
            "type": "algorand",
            "requestId": request.requestId,
            "address": response.address,
            "signature": signature.base64URLEncodedString(),
            "device": device
        ])

        if let postResponse = try? JSONDecoder().decode(ResponseJsonWithError.self, from: responseData), postResponse.error != nil
        {
            passKeyService.deletePassKeysForOriginAndUsername(origin: request.origin, username: response.address)
            throw LiquidAuthError.generalError()
        } else {
            return LiquidAuthResponse(credentialId: response.credentialId.base64URLEncodedString())
        }
    }
    
    private func makeCredentialObject(credentialId: Data, clientDataJSON: Data, attestationObject: Data) -> [String: Any] {
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
    
    private func extractRelyingPartyId(json: [String: Any]?) -> String? {
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
    
    private func clientData(type: String, challengeUrl: String, relyingParty: String) throws -> Data? {
        let data = ClientData(type: type, challenge: challengeUrl, origin: "https://\(relyingParty)")
        return try? JSONEncoder().encode(data)
    }
    
    private func signChallenge(signingAccount: AccountInformation, challenge: Data) async throws -> Data? {
        guard let detail = signingAccount.hdWalletAddressDetail,
              let schemaPath = Bundle.main.path(forResource: "auth.request", ofType: "json"),
              let sdk = try await passKeyService.makeSigningSDK(account: signingAccount) else {
            return nil
        }
        
        //if we have valid json we can validate it
        if let challengeString = String(data: challenge, encoding: .utf8),
           let decodedJSON = liquidAuthSDK.decodedBase64UrlAsJSON(challengeString) {
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
}

fileprivate enum SignalType : String {
    case answer
    case offer
}

fileprivate final class ResponseJsonWithError : Codable {
    let error: String?
}

fileprivate final class AssertionResponseJsonIdHolder : Codable {
    let id: String
}

fileprivate final class AssertionOptionsResponseJson : Codable {
    let rp: AssertionResponseJsonIdHolder?
    let rpId: String?
    let challenge: String?
}

fileprivate struct ClientData : Codable {
    let type: String
    let challenge: String
    let origin: String
}

fileprivate struct PostOptionsResult {
    let challengeUrl: String
    let relyingPartyId: String
    let relyingPartyIdHash: Data
}

fileprivate struct AssertionPayloadResponseBody : Codable {
    let clientDataJSON: String
    let authenticatorData: String
    let signature: String
}

fileprivate struct AssertionPayload : Codable {
    let id: String
    let type: String
    let userHandle: String
    let rawId: String
    
    let response: AssertionPayloadResponseBody
    
    init(credentialId: String, address: String, clientData: Data, authenticatorData: Data, p256SignatureDer: Data) {
        id = credentialId
        type = "public-key"
        userHandle = address
        rawId = credentialId
        response = AssertionPayloadResponseBody(
            clientDataJSON: clientData.base64URLEncodedString(),
            authenticatorData: authenticatorData.base64URLEncodedString(),
            signature: p256SignatureDer.base64URLEncodedString())
    }
}
