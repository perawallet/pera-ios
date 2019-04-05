//
//  API+Account.swift
//  algorand
//
//  Created by Omer Emre Aslan on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    @discardableResult
    func fetchAccount(
        with draft: AccountFetchDraft,
        then completion: CompletionHandler<Account>? = nil
    ) -> EndpointInteractable? {
        
        let address = draft.publicKey
        
        return send(
            Endpoint<Account>(Path("/v1/account/\(address)"))
                .httpMethod(.get)
                .handler { response in
                    completion?(response)
                }
        )
    }
}
