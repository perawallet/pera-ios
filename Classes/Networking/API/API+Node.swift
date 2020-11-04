//
//  API+Node.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension AlgorandAPI {
    @discardableResult
    func checkNodeHealth(with draft: NodeTestDraft, then handler: BoolHandler? = nil) -> EndpointOperatable? {
        let resultHandler: (Response.RawResult) -> Void = { result in
            switch result {
            case .success:
                handler?(true)
            case .failure:
                handler?(false)
            }
        }
        
        let address = draft.address
        let token = draft.token
        
        guard let url = URL(string: address) else {
            handler?(false)
            return nil
        }
        
        return EndpointBuilder(api: self)
            .base(url.absoluteString)
            .path("/health")
            .validateResponseBeforeEndpointCompleted(false)
            .headers(nodeHealthHeaders(for: token))
            .completionHandler(resultHandler)
            .build()
            .send()
    }
    
    @discardableResult
    func waitRound(
        with draft: WaitRoundDraft,
        then handler: @escaping (Response.ModelResult<RoundDetail>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(algodBase)
            .path("/v2/status/wait-for-block-after/\(draft.round)")
            .headers(algodAuthenticatedHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
}
