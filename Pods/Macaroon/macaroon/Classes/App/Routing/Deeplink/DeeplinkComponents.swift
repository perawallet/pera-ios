// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public struct DeeplinkComponents {
    public let subdomain: String
    public let path: String
    public let queryItems: [URLQueryItem]
    public let url: URL

    init(
        url: URL,
        deeplinkHost: String
    ) {
        self.url = url
        
        guard let host = url.host.unwrapConditionally(where: { $0.hasSuffix(deeplinkHost) }) else {
            subdomain = ""
            path = ""
            queryItems = []
            return
        }
        if host == deeplinkHost {
            subdomain = ""
        } else {
            let hostComponents = url.host.nonNil.components(separatedBy: ".")
            subdomain = hostComponents.first.nonNil
        }

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        path = urlComponents.unwrap(\.path, or: "")
        queryItems = urlComponents.unwrap(\.queryItems, or: [])
    }
}
