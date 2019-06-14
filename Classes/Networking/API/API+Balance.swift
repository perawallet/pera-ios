//
//  API+Balance.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    
    @discardableResult
    func fetchDepositInformation(completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/{username}/deposit/{type}/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
            }
        )
    }
    
    @discardableResult
    func fetchCoinlistTransactions(completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/{username}/transactions/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
            }
        )
    }
    
    @discardableResult
    func getWithdrawalInformations(completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/{username}/withdraw/{type}/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
            }
        )
    }
    
    @discardableResult
    func withdrawUSD(completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/{username}/withdraw/{type}/"))
                .base(Environment.current.cointlistApi)
                .httpMethod(.post)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
            }
        )
    }
}
