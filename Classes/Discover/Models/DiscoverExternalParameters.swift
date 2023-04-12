// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   DiscoverExternalParameters.swift

import Foundation

protocol DiscoverExternalParameters {
    var url: URL { get }
}

struct DiscoverExternalLinkParameters: DiscoverExternalParameters {
    let url: URL
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

    func createInAppBrowserDeeplinkURL(on network: ALGAPI.Network) -> URL? {
        let parameters = DiscoverExternalLinkParameters(url: self)

        return DiscoverURLGenerator.generateURL(
            destination: .redirection(parameters, network),
            theme: .unspecified,
            session: nil
        )
    }
}
