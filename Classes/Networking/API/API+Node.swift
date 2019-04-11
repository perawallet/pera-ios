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
        
        
        return send(
            Endpoint<NoObject>(Path("/health"))
                .httpMethod(.get)
                .base(address)
                .httpHeaders(httpHeaders)
                .handler { response in
                    completion?(!response.isFailed)
            }
        )
    }
}
