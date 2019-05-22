//
//  API+Node.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func checkHealth(
        with draft: NodeTestDraft,
        then completion: BoolHandler? = nil
        ) -> EndpointInteractable? {
        
        let address = draft.address
        let token = draft.token
        
        var httpHeaders = super.commonHttpHeaders
        httpHeaders.append(.custom(header: "X-Algo-API-Token", value: token))
        
        guard let url = URL(string: address) else {
            completion?(false)
            return nil
        }
        
        return sendInvalidated(
            Endpoint<NoObject>(Path("/health"))
                .httpMethod(.get)
                .base(url.absoluteString)
                .httpHeaders(httpHeaders)
                .handler { response in
                    completion?(!response.isFailed)
                }
        )
    }
    
    @discardableResult
    func waitRound(
        with draft: WaitRoundDraft,
        then completion: APICompletionHandler<RoundDetail>? = nil
        ) -> EndpointInteractable? {
        
        return send(
            Endpoint<RoundDetail>(Path("/v1/status/wait-for-block-after/\(draft.round)"))
                .httpMethod(.get)
                .handler { response in
                    completion?(response)
                }
        )
    }
}
