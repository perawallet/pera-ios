//
//  FeedbackDraft.swift

import Magpie

struct FeedbackDraft: JSONObjectBody {
    var note: String
    var category: String
    var email: String
    var address: String?

    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.note, note))
        params.append(.init(.category, category))
        params.append(.init(.email, email))
        params.append(.init(.address, address, .setIfPresent))
        return params
    }
}
