//
//  API+Feedback.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension API {
    
    @discardableResult
    func getFeedbackCategories(completion: APICompletionHandler<[FeedbackCategory]>? = nil) -> EndpointInteractable? {
        return send(
            Endpoint<[FeedbackCategory]>(Path("/api/feedback/categories/"))
                .base(Environment.current.mobileApi)
                .httpMethod(.get)
                .handler { response in
                    completion?(response)
                }
        )
    }
    
    @discardableResult
    func sendFeedback(with draft: FeedbackDraft, completion: APICompletionHandler<Feedback>? = nil) -> EndpointInteractable? {
        var params: Params = [
            .custom(key: AlgorandParamPairKey.note, value: draft.note),
            .custom(key: AlgorandParamPairKey.category, value: draft.category)
        ]
        params.appendIfPresent(draft.email, for: AlgorandParamPairKey.email)
        
        return send(
            Endpoint<Feedback>(Path("/api/feedback/"))
                .base(Environment.current.mobileApi)
                .httpMethod(.post)
                .body(params)
                .handler { response in
                    completion?(response)
                }
        )
    }
}
