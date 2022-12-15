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

//   DiscoverSocialMediaLinkParserTests.swift

import XCTest

@testable import pera_staging

final class DiscoverSocialMediaLinkParserTests: XCTestCase {

    func testTwitterUsername() throws {
        let parser = DiscoverSocialMediaLinkParser()

        let peraUserExample = URL(string: "https://twitter.com/PeraAlgoWallet")!
        let peraDeeplink = try parser.parse(url: peraUserExample)

        XCTAssertNoThrow(peraDeeplink)
        XCTAssertEqual(peraDeeplink, URL(string: "twitter://user?screen_name=PeraAlgoWallet"))

        let invalidURLExample = URL(string: "https://twitter.com/home")!
        let invalidURL2Example = URL(string: "https://twitter.com/explore")!
        let invalidURL3Example = URL(string: "https://twitter.com/settings")!
        let invalidURL4Example = URL(string: "https://twitter.com/notifications")!
        XCTAssertThrowsError(try parser.parse(url: invalidURLExample))
        XCTAssertThrowsError(try parser.parse(url: invalidURL2Example))
        XCTAssertThrowsError(try parser.parse(url: invalidURL3Example))
        XCTAssertThrowsError(try parser.parse(url: invalidURL4Example))

        let hipoUserExample = URL(string: "https://m.twitter.com/hipolabs")!
        let hipoDeeplink = try parser.parse(url: hipoUserExample)

        XCTAssertNoThrow(hipoDeeplink)
        XCTAssertEqual(hipoDeeplink, URL(string: "twitter://user?screen_name=hipolabs"))

        let tinymanUserExample = URL(string: "twitter://user?screen_name=tinyman")!
        let tinymanDeeplink = try parser.parse(url: tinymanUserExample)

        XCTAssertNoThrow(tinymanDeeplink)
        XCTAssertEqual(tinymanDeeplink, URL(string: "twitter://user?screen_name=tinyman"))
    }

    func testDiscordInvite() throws {
        let parser = DiscoverSocialMediaLinkParser()

        let peraDiscordExample = URL(string: "https://discord.com/invite/gR2UdkCTXQ")!
        let peraDeeplink = try parser.parse(url: peraDiscordExample)

        XCTAssertNoThrow(peraDeeplink)
        XCTAssertEqual(peraDeeplink, URL(string: "com.hammerandchisel.discord://discord.com/invite/gR2UdkCTXQ"))

        let invalidURLExample = URL(string: "https://discord.com/invites/gR2UdkCTXQ")!
        let invalidURL2Example = URL(string: "https://discord.com/gR2UdkCTXQ")!
        XCTAssertThrowsError(try parser.parse(url: invalidURLExample))
        XCTAssertThrowsError(try parser.parse(url: invalidURL2Example))

        let tinymanUserExample = URL(string: "com.hammerandchisel.discord://discord.com/invite/wvHnAdmEv6")!
        let tinymanDeeplink = try parser.parse(url: tinymanUserExample)

        XCTAssertNoThrow(tinymanDeeplink)
        XCTAssertEqual(tinymanDeeplink, URL(string: "com.hammerandchisel.discord://discord.com/invite/wvHnAdmEv6"))
    }

    func testTelegramInvite() throws {
        let parser = DiscoverSocialMediaLinkParser()

        let peraTelegramExample = URL(string: "https://t.me/PeraWallet")!
        let peraDeeplink = try parser.parse(url: peraTelegramExample)

        XCTAssertNoThrow(peraDeeplink)
        XCTAssertEqual(peraDeeplink, URL(string: "tg://resolve?domain=PeraWallet"))

        let invalidURLExample = URL(string: "https://t.me/PeraWallet/Test")!
        XCTAssertThrowsError(try parser.parse(url: invalidURLExample))

        let tinymanUserExample = URL(string: "tg://resolve?domain=tinymanofficial")!
        let tinymanDeeplink = try parser.parse(url: tinymanUserExample)

        XCTAssertNoThrow(tinymanDeeplink)
        XCTAssertEqual(tinymanDeeplink, URL(string: "tg://resolve?domain=tinymanofficial"))
    }
}
