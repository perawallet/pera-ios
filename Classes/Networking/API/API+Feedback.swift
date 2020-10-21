//
//  API+Feedback.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension AlgorandAPI {
    @discardableResult
    func getFeedbackCategories(
        then handler: @escaping (Response.ModelResult<[FeedbackCategory]>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/feedback/categories/")
            .headers(mobileApiHeaders())
            .completionHandler(handler)
            .build()
            .send()
    }
    
    @discardableResult
    func sendFeedback(
        with draft: FeedbackDraft,
        then handler: @escaping (Response.ModelResult<Feedback>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .base(mobileApiBase)
            .path("/api/feedback/")
            .method(.post)
            .headers(mobileApiHeaders())
            .body(draft)
            .completionHandler(handler)
            .build()
            .send()
    }
}
