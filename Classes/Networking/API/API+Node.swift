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
    func checkNodeHealth(with draft: NodeTestDraft, then handler: BoolHandler? = nil) -> EndpointOperatable? {
        let resultHandler: Endpoint.RawResultHandler = { result in
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
        
        return Endpoint(path: Path("/health"))
            .httpMethod(.get)
            .validateResponseFirstWhenReceived(false)
            .base(url.absoluteString)
            .httpHeaders(nodeHealthHeaders(for: token))
            .resultHandler(resultHandler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func waitRound(
        with draft: WaitRoundDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<RoundDetail>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/v2/status/wait-for-block-after/\(draft.round)"))
            .base(algodBase)
            .httpMethod(.get)
            .httpHeaders(algodAuthenticatedHeaders())
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
