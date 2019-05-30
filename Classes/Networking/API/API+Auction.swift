//
//  API+Auctions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    
    @discardableResult
    func fetchPastAuctions(for top: Int, completion: APICompletionHandler<[Auction]>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        var params: Params = [.custom(key: AlgorandParamPairKey.accessToken, value: coinlistToken)]
        params.appendIfPresent(top, for: AlgorandParamPairKey.top)
        
        return send(
            Endpoint<[Auction]>(Path("/api/algorand/auctions/"))
                .base(Environment.current.cointlistApi)
                .query(params)
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchActiveAuction(completion: APICompletionHandler<ActiveAuction>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<ActiveAuction>(Path("/api/algorand/last-auction-status/"))
                .base(Environment.current.cointlistApi)
                .query([
                    .custom(key: AlgorandParamPairKey.accessToken, value: coinlistToken)
                ])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func authenticateCoinlist(
        with draft: CoinlistAuthenticationDraft,
        completion: APICompletionHandler<CoinlistAuthentication>? = nil
    ) -> EndpointInteractable? {
        
        let params: Params = [
            .custom(key: AlgorandParamPairKey.clientId, value: draft.clientId),
            .custom(key: AlgorandParamPairKey.clientSecret, value: draft.clientSecret),
            .custom(key: AlgorandParamPairKey.code, value: draft.code),
            .custom(key: AlgorandParamPairKey.grantType, value: draft.grantType),
            .custom(key: AlgorandParamPairKey.redirectUri, value: draft.redirectURI)
        ]
        
        return send(
            Endpoint<CoinlistAuthentication>(Path("/oauth/token/"))
                .base(Environment.current.cointlistApi)
                .httpMethod(.post)
                .body(params)
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchCoinlistUser(completion: APICompletionHandler<CoinlistUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<CoinlistUser>(Path("/api/v1/me/"))
                .base(Environment.current.cointlistApi)
                .query([
                    .custom(key: AlgorandParamPairKey.accessToken, value: coinlistToken)
                ])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchAuctionDetails(
        with id: String,
        completion: APICompletionHandler<Auction>? = nil
    ) -> EndpointInteractable? {
        
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<Auction>(Path("/api/algorand/auctions/\(id)/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchAuctionStatus(
        for id: String,
        completion: APICompletionHandler<ActiveAuction>? = nil
    ) -> EndpointInteractable? {
        
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<ActiveAuction>(Path("/api/algorand/auctions/\(id)/status/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchChartData(
        for auctionId: String,
        completion: APICompletionHandler<[ChartData]>? = nil
    ) -> EndpointInteractable? {
        
        return send(
            Endpoint<[ChartData]>(Path("/api/algorand/auctions/\(auctionId)/chart_data/"))
                .base(Environment.current.cointlistApi)
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchAuctionUser(completion: APICompletionHandler<AuctionUser>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken,
            let userId = session?.coinlistUserId else {
            return nil
        }
        
        return send(
            Endpoint<AuctionUser>(Path("/api/algorand/users/\(userId)/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func fetchBids(in auction: String, for userId: String, completion: APICompletionHandler<[Bid]>? = nil) -> EndpointInteractable? {
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<[Bid]>(Path("/api/algorand/auctions/\(auction)/bids/"))
                .base(Environment.current.cointlistApi)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .query([
                    .custom(key: AlgorandParamPairKey.username, value: userId)
                ])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func placeBid(
        with dataString: String,
        for auction: String,
        completion: APICompletionHandler<BidResponse>? = nil
    ) -> EndpointInteractable? {
        
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<BidResponse>(Path("/api/algorand/auctions/\(auction)/bids/"))
                .base(Environment.current.cointlistApi)
                .httpMethod(.post)
                .body([
                    .custom(key: AlgorandParamPairKey.bid, value: dataString)
                ])
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func retractBid(
        with id: String,
        from auction: String,
        completion: APICompletionHandler<NoObject>? = nil
    ) -> EndpointInteractable? {
        
        guard let coinlistToken = session?.coinlistToken else {
            return nil
        }
        
        return send(
            Endpoint<NoObject>(Path("/api/algorand/auctions/\(auction)/bids/\(id)/"))
                .base(Environment.current.cointlistApi)
                .httpMethod(.delete)
                .httpHeaders([.custom(header: "Authorization", value: "Bearer \(coinlistToken)")])
                .handler { response in
                    completion?(response)
                }
        )
    }
}
