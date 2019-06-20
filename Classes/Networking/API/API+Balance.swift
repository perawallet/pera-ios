//
//  API+Balance.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum DepositType: String {
    case usd = "USD"
    case btc = "ETH"
    case eth = "BTC"
}

extension API {
    
    @discardableResult
    func fetchDepositInformation(for type: DepositType, completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/\(userId)/deposit/\(type.rawValue)/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchCoinlistTransactions(completion: APICompletionHandler<[CoinlistTransaction]>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<[CoinlistTransaction]>(Path("/api/algorand/users/\(userId)/transactions/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func getWithdrawalInformations(
        for type: DepositType,
        completion: APICompletionHandler<[CoinlistTransaction]>? = nil
    ) -> EndpointInteractable? {
    
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<[CoinlistTransaction]>(Path("/api/algorand/users/\(userId)/withdraw/\(type.rawValue)/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func withdrawUSD(for type: DepositType, completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/\(userId)/withdraw/\(type.rawValue)/"))
                .base(Environment.current.cointlistApi)
                .httpMethod(.post)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
}
