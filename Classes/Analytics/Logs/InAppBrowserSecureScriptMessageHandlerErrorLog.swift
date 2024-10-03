// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   InAppBrowserSecureScriptMessageHandlerErrorLog.swift

import Foundation
import MacaroonVendors
import WebKit

struct InAppBrowserSecureScriptMessageHandlerLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
    
    fileprivate init(
        scriptMessageHandler: WKScriptMessageHandler,
        message: String?,
        screen: String
    ) {

        self.name = .inAppBrowserSecureScriptMessageHandler
        self.metadata = [
            .scriptMessageHandler: scriptMessageHandler,
            .scriptMessage: message as Any,
            .screenName: screen
        ]
    }
}

extension ALGAnalyticsLog where Self == InAppBrowserSecureScriptMessageHandlerLog {
    static func inAppBrowserSecureScriptMessageHandler(
        scriptMessageHandler: WKScriptMessageHandler,
        scriptMessage: String?,
        screenName: String
    ) -> Self {
        return InAppBrowserSecureScriptMessageHandlerLog(
            scriptMessageHandler: scriptMessageHandler,
            message: scriptMessage,
            screen: screenName
        )
    }
}
