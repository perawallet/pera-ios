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

//   InAppBrowserUserContentController.swift

import Foundation
import WebKit

public final class InAppBrowserUserContentController: WKUserContentController {
    private var handlers: [String: InAppBrowserSecureScriptMessageHandler] = [:]

    public func add<T>(
        secureScriptMessageHandler: WKScriptMessageHandler,
        forMessage msg: T
    ) where T: InAppBrowserScriptMessage {
        add(
            secureScriptMessageHandler: secureScriptMessageHandler,
            forName: msg.rawValue
        )
    }

    public func add(
        secureScriptMessageHandler: WKScriptMessageHandler,
        forName name: String
    ) {
        let handler = InAppBrowserSecureScriptMessageHandler(handler: secureScriptMessageHandler)
        handlers[name] = handler
        add(
            handler,
            name: name
        )
    }

    public func removeScriptMessageHandlers<T>(forMessages msgs: some Collection<T>)
    where T: InAppBrowserScriptMessage {
        msgs.forEach(removeScriptMessageHandler)
    }

    public func removeScriptMessageHandler<T>(forMessage msg: T)
    where T: InAppBrowserScriptMessage {
        handlers[msg.rawValue] = nil
        removeScriptMessageHandler(forName: msg.rawValue)
    }
}

public protocol InAppBrowserScriptMessage:
    RawRepresentable,
    CaseIterable
where RawValue == String {}

public struct NoInAppBrowserScriptMessage: InAppBrowserScriptMessage {
    public var rawValue: String = ""

    public static var allCases: [NoInAppBrowserScriptMessage] = []

    public init?(rawValue: String) {
        return nil
    }
}

public final class InAppBrowserSecureScriptMessageHandler:
    NSObject,
    WKScriptMessageHandler {
    private var handler: WKScriptMessageHandler?

    public init(handler: WKScriptMessageHandler) {
        self.handler = handler
    }

    /// <mark>
    /// WKScriptMessageHandler
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        handler?.userContentController(
            userContentController,
            didReceive: message
        )
    }
}
