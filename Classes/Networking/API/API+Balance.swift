//
//  API+Balance.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum DepositType: String {
    case usd = "usd"
    case btc = "eth"
    case eth = "btc"
}

extension API {
    
    @discardableResult
    func fetchBlockchainDepositInformation(
        for type: DepositType,
        completion: APICompletionHandler<BlockchainInstruction>? = nil
    ) -> EndpointInteractable? {
        
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<BlockchainInstruction>(Path("/api/algorand/users/\(userId)/deposit/\(type.rawValue)/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchUSDDepositInformation(completion: APICompletionHandler<USDWireInstruction>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
                return nil
        }
        
        return send(
            Endpoint<USDWireInstruction>(Path("/api/algorand/users/\(userId)/deposit/usd/"))
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
}
