//
//  DeviceRegistrationDraft.swift

import Magpie

struct DeviceRegistrationDraft: JSONObjectBody {
    let pushToken: String?
    let platform = "ios"
    let model = UIDevice.current.model
    let locale = Locale.current.languageCode ?? "en"
    var accounts: [String] = []
    
    var bodyParams: [BodyParam] {
        var params: [BodyParam] = []
        params.append(.init(.platform, platform))
        params.append(.init(.model, model))
        params.append(.init(.locale, locale))
        params.append(.init(.accounts, accounts))
        params.append(.init(.pushToken, pushToken, .setIfPresent))
        return params
    }
}
