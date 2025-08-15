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

//   WCTransactionFailToConnectErrorLog.swift

import Foundation

<<<<<<<< HEAD:PeraWalletCore/Analytics/Events/WalletConnect/WCTransactionRequestSDKErrorEvent.swift
public struct WCTransactionRequestSDKErrorEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata
========
struct WCTransactionFailToConnectErrorLog: ALGAnalyticsLog {
    let name: ALGAnalyticsLogName
    let metadata: ALGAnalyticsMetadata
>>>>>>>> main:PeraWalletCore/Analytics/Logs/WCTransactionFailToConnectErrorLog.swift
    
    fileprivate init(
        url: WalletConnectURL
    ) {
        self.name = .walletConnectTransactionFailToConnectError
        
        self.metadata  = [
            .wcVersion: WalletConnectProtocolID.v1.rawValue,
            .wcRequestURL: Self.regulate(url.absoluteString)
        ]
    }
}

<<<<<<<< HEAD:PeraWalletCore/Analytics/Events/WalletConnect/WCTransactionRequestSDKErrorEvent.swift
extension AnalyticsEvent where Self == WCTransactionRequestSDKErrorEvent {
    public static func wcTransactionRequestSDKError(
        error: Error?,
========
extension ALGAnalyticsLog where Self == WCTransactionFailToConnectErrorLog {
    static func wcTransactionFailToConnectError(
>>>>>>>> main:PeraWalletCore/Analytics/Logs/WCTransactionFailToConnectErrorLog.swift
        url: WalletConnectURL
    ) -> Self {
        return WCTransactionFailToConnectErrorLog(url: url)
    }
}
