//
//  AlgorandParamPairKey.swift
//  algorand
//
//  Created by Omer Emre Aslan on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum RequestParameter: String, JSONBodyRequestParameter {
    case address = "address"
    case firstRound = "firstRound"
    case lastRound = "lastRound"
    case accessToken = "access_token"
    case top = "top"
    case username = "username"
    case bid = "SignedBinary"
    case max = "max"
    case from = "fromDate"
    case to = "toDate"
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code = "code"
    case grantType = "grant_type"
    case redirectUri = "redirect_uri"
    case algoDollarConversion = "symbol"
    case note = "note"
    case email = "email"
    case category = "category"
    case pushToken = "push_token"
    case platform = "platform"
    case model = "model"
    case locale = "locale"
    case accounts = "accounts"
    case transactionId = "transaction_id"
    case assetId = "assetIdx"
    case sender = "sender_address"
    case receiver = "receiver_address"
    case asset = "asset_id"
    case limit = "limit"
    case query = "q"
    case offset = "offset"
}
