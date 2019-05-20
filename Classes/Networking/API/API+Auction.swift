//
//  API+Auctions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import Crypto

extension API {
    
    @discardableResult
    func fetchPastAuctions(
        with draft: AuctionDraft,
        completion: APICompletionHandler<[Auction]>? = nil
    ) -> EndpointInteractable? {
        
        var params: Params = [.custom(key: AlgorandParamPairKey.accessToken, value: draft.accessToken)]
        params.appendIfPresent(draft.topCount, for: AlgorandParamPairKey.top)
        
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
    func fetchActiveAuction(
        with draft: AuctionDraft,
        completion: APICompletionHandler<ActiveAuction>? = nil
    ) -> EndpointInteractable? {
        
        return send(
            Endpoint<ActiveAuction>(Path("/api/algorand/last-auction-status/"))
                .base(Environment.current.cointlistApi)
                .query([
                    .custom(key: AlgorandParamPairKey.accessToken, value: draft.accessToken)
                ])
                .handler { response in
                    completion?(response)
                }
        )
    }
}
