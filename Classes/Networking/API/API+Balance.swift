//
//  API+Balance.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum DepositType: String, Model, Encodable {
    case usd = "usd"
    case btc = "btc"
    case eth = "eth"
}

extension API {
    @discardableResult
    func fetchBlockchainDepositInformation(
        for type: DepositType,
        then handler: @escaping Endpoint.DefaultResultHandler<BlockchainInstruction>
    ) -> EndpointOperatable? {
        guard let userId = session.coinlistUserId else {
            return nil
        }
        
        return Endpoint(path: Path("/api/algorand/users/\(userId)/deposit/\(type.rawValue)/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchUSDDepositInformation(then handler: @escaping Endpoint.DefaultResultHandler<USDWireInstruction>) -> EndpointOperatable? {
        guard let userId = session.coinlistUserId else {
            return nil
        }
        
        return Endpoint(path: Path("/api/algorand/users/\(userId)/deposit/usd/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchCoinlistTransactions(then handler: @escaping Endpoint.DefaultResultHandler<[CoinlistTransaction]>) -> EndpointOperatable? {
        guard let userId = session.coinlistUserId else {
            return nil
        }
        
        return Endpoint(path: Path("/api/algorand/users/\(userId)/transactions/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
