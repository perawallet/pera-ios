// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   URL+Extensions.swift

import Foundation
import MacaroonUtils

extension URL {
    var presentationString: String? {
        let host = host.unwrapNonEmptyString() ?? absoluteString
        return host.without(prefix: "www.")
    }
    var isMailURL: Bool {
        return scheme?.lowercased() == "mailto"
    }
    var isWebURL: Bool {
        return (scheme?.lowercased() == "http" || scheme?.lowercased() == "https") && host != nil
    }
    var isPeraURL: Bool {
        /// <note>
        /// Swift `Regex` can NOT support this pattern at the moment.
        let pattern = #"^https://([\da-z-]+\.)*(?<!web\.)perawallet\.app((?:/.*)?|(?:\?.*)?|(?:#.*)?)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: absoluteString.utf16.count)
        return regex.firstMatch(in: absoluteString, options: [], range: range) != nil
    }
}

extension URL {
    func straightened() -> URL? {
        var components = URLComponents(string: absoluteString)

        /// <warning>
        /// Only HTTP and HTTPS schemes are supported. Otherwise, it crashes.
        switch components?.scheme {
        case .none:
            components?.scheme = "https"
            return components?.url
        case "http", "https":
            return components?.url
        default:
            return nil
        }
    }
}

extension URL {
    func extractBaseURL() -> URL? {
        let baseURLString = self.scheme.flatMap { scheme in
            self.host.map { host in
                "\(scheme)://\(host)/"
            }
        }
        guard let baseURLString else { return nil }
        return URL(string: baseURLString)
    }
}

extension URL {
    var inAppBrowserDeeplinkURL: URL? {
        let browserValidationHost = "in-app-browser"
        let urlHost = self.host

        guard urlHost == browserValidationHost else {
            return nil
        }

        guard let queryParameters, let urlString = queryParameters["url"] else {
            return nil
        }

        return URL(string: urlString)
    }
}

extension URL {

    var externalDeepLink: ExternalDeepLink? {
        let pattern = #"^perawallet://([^?]+)(\?.+)?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(location: 0, length: absoluteString.utf16.count)
        if let match = regex.firstMatch(in: absoluteString, options: [], range: range) {
            let typeString = (absoluteString as NSString).substring(with: match.range(at: 1))

            var path: String?
            if let paramsString = match.range(at: 2).location != NSNotFound ? (absoluteString as NSString).substring(with: match.range(at: 2)) : nil {
                if let urlComponents = URLComponents(string: "\(paramsString)") {
                    if let pathValue = urlComponents.queryItems?.first(where: { $0.name == "path" })?.value {
                        path = pathValue
                    }
                }
            }

            switch typeString {
            case "discover":
                return .discover(path: path)
            case "staking":
                return .staking(path: path)
            case "cards":
                return .cards(path: path)
            default:
                return nil
            }
        }

        return nil
    }
}
