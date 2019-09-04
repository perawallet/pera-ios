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
    func fetchPastAuctions(for top: Int, then handler: @escaping Endpoint.DefaultResultHandler<[Auction]>) -> EndpointOperatable? {
        guard let coinlistToken = session.coinlistToken else {
            return nil
        }
        
        return Endpoint(path: Path("/api/algorand/auctions/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .query(CoinlistTokenQuery(token: coinlistToken, top: top))
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchActiveAuction(then handler: @escaping Endpoint.DefaultResultHandler<ActiveAuction>) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/last-auction-status/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func authenticateCoinlist(
        with draft: CoinlistAuthenticationDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<CoinlistAuthentication>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/oauth/token/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.post)
            .httpBody(draft)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchCoinlistUser(then handler: @escaping Endpoint.DefaultResultHandler<CoinlistUser>) -> EndpointOperatable? {
        guard let coinlistToken = session.coinlistToken else {
            return nil
        }
        
        return Endpoint(path: Path("/api/v1/me/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .query(CoinlistTokenQuery(token: coinlistToken, top: nil))
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchAuctionDetails(with id: String, then handler: @escaping Endpoint.DefaultResultHandler<Auction>) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/auctions/\(id)/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchAuctionStatus(for id: String, then handler: @escaping Endpoint.DefaultResultHandler<ActiveAuction>) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/auctions/\(id)/status/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchChartData(for auctionId: String, then handler: @escaping Endpoint.DefaultResultHandler<[ChartData]>) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/auctions/\(auctionId)/chart_data/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchAuctionUser(then handler: @escaping Endpoint.DefaultResultHandler<AuctionUser>) -> EndpointOperatable? {
        guard let userId = session.coinlistUserId else {
            return nil
        }
        
        return Endpoint(path: Path("/api/algorand/users/\(userId)/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func fetchBids(
        in auction: String,
        for userId: String,
        then handler: @escaping Endpoint.DefaultResultHandler<[Bid]>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/auctions/\(auction)/bids/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.get)
            .query(CoinlistUserQuery(userId: userId))
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func placeBid(
        with dataString: String,
        for auction: String,
        then handler: @escaping Endpoint.DefaultResultHandler<BidResponse>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/auctions/\(auction)/bids/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.post)
            .httpBody(BidDraft(bidData: dataString))
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func retractBid(
        with id: String,
        from auction: String,
        then handler: @escaping Endpoint.RawResultHandler
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/algorand/auctions/\(auction)/bids/\(id)/"))
            .base(Environment.current.cointlistApi)
            .httpMethod(.delete)
            .httpHeaders(coinlistTokenHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
