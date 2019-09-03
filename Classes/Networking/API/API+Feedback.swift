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
    func getFeedbackCategories(then handler: @escaping Endpoint.DefaultResultHandler<[FeedbackCategory]>) -> EndpointOperatable {
        return Endpoint(path: Path("/api/feedback/categories/"))
            .base(Environment.current.mobileApi)
            .httpMethod(.get)
            .resultHandler(handler)
            .buildAndSend(self)
    }
    
    @discardableResult
    func sendFeedback(
        with draft: FeedbackDraft,
        then handler: @escaping Endpoint.DefaultResultHandler<Feedback>
    ) -> EndpointOperatable {
        return Endpoint(path: Path("/api/feedback/"))
            .base(Environment.current.mobileApi)
            .httpMethod(.post)
            .httpBody(draft)
            .resultHandler(handler)
            .buildAndSend(self)
    }
}
