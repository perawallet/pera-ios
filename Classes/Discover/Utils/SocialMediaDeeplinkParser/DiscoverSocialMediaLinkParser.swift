// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   DiscoverSocialMediaLinkParser.swift

import Foundation

final class DiscoverSocialMediaLinkParser {

    /// <note>: parse function description
    /// parse function gets the URL from InAppBrowser and checks the URL
    /// If URL is valid for specific social media apps, it will return the necessary deeplink URLs to parse
    /// example: https://twitter.com/PeraAlgoWallet it will be converted to => twitter://user?screen_name=PeraAlgoWallet
    func parse(url: URL) throws -> URL {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw DiscoverSocialMediaLinkParserError.invalidSocialUrl(url)
        }

        switch urlComponents.scheme {
        case "twitter":
            guard urlComponents.host == "user",
                  let username = url.queryParameters?["screen_name"] else {
                throw DiscoverSocialMediaLinkParserError.invalidPath(url)
            }

            return try generateTwitterDeeplink(for: username, fallback: url)
        case "com.hammerandchisel.discord":
            guard urlComponents.host == "discord.com" else {
                throw DiscoverSocialMediaLinkParserError.invalidPath(url)
            }

            return try generateDiscordDeeplink(for: url)
        case "tg":
            guard urlComponents.host == "resolve",
                  let groupName = url.queryParameters?["domain"] else {
                throw DiscoverSocialMediaLinkParserError.invalidPath(url)
            }

            return try generateTelegramDeeplink(with: groupName, fallback: url)
        case "https", "http":
            break
        default:
            throw DiscoverSocialMediaLinkParserError.invalidSocialUrl(url)
        }

        /// <note>:
        /// Web URL parsing
        switch urlComponents.host {
        case "twitter.com", "m.twitter.com", "www.twitter.com", "mobile.twitter.com":
            guard url.pathComponents.count == 2 else {
                throw DiscoverSocialMediaLinkParserError.invalidSocialUrl(url)
            }

            let username = url.pathComponents.last

            return try generateTwitterDeeplink(for: username, fallback: url)
        case "discord.com":
            return try generateDiscordDeeplink(for: url)

        case "t.me", "telegram.me":
            guard url.pathComponents.count == 2 else {
                throw DiscoverSocialMediaLinkParserError.invalidSocialUrl(url)
            }

            var pathComponents = url.pathComponents
            pathComponents.removeAll { path in
                path == "/"
            }

            let groupName = pathComponents.last
            return try generateTelegramDeeplink(with: groupName, fallback: url)

        default:
            throw DiscoverSocialMediaLinkParserError.invalidSocialUrl(url)
        }
    }

    private func generateTwitterDeeplink(for username: String?, fallback: URL) throws -> URL {
        guard let username else {
            throw DiscoverSocialMediaLinkParserError.invalidPath(fallback)
        }

        switch username {
        case "home", "explore", "messages", "notifications", "settings":
            throw DiscoverSocialMediaLinkParserError.invalidPath(fallback)
        default:
            break
        }

        return URL(string: "twitter://user?screen_name=\(username)")!
    }

    private func generateDiscordDeeplink(for url: URL) throws -> URL {
        guard url.pathComponents.count == 3 else {
            throw DiscoverSocialMediaLinkParserError.invalidSocialUrl(url)
        }

        var pathComponents = url.pathComponents
        pathComponents.removeAll { path in
            path == "/"
        }

        guard pathComponents.first == "invite" else {
            throw DiscoverSocialMediaLinkParserError.invalidPath(url)
        }

        let inviteID = pathComponents.last

        guard let inviteID else {
            throw DiscoverSocialMediaLinkParserError.invalidPath(url)
        }

        return URL(string: "com.hammerandchisel.discord://discord.com/invite/\(inviteID)")!
    }

    private func generateTelegramDeeplink(with groupName: String?, fallback: URL) throws -> URL {
        guard let groupName else {
            throw DiscoverSocialMediaLinkParserError.invalidPath(fallback)
        }

        return URL(string: "tg://resolve?domain=\(groupName)")!
    }
}

enum DiscoverSocialMediaLinkParserError: Error {
    case invalidSocialUrl(URL)
    case invalidPath(URL)
}
