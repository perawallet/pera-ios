//
//  API+Feedback.swift

import Magpie

extension AlgorandAPI {
    @discardableResult
    func getFeedbackCategories(
        then handler: @escaping (Response.Result<[FeedbackCategory], HIPAPIError>) -> Void
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
        then handler: @escaping (Response.Result<Feedback, HIPAPIError>) -> Void
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
