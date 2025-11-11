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

//   InAppBrowserScripts.swift

import WebKit

enum InAppBrowserScript {
    case selection
    case navigation
    case peraConnect
    case bidaliPayment(config: BidaliConfig, balance: String)

    var userScript: WKUserScript {
        let source: String
        switch self {
        case .selection:
            source = Scripts.selection
        case .navigation:
            source = Scripts.navigation
        case .peraConnect:
            source = Scripts.peraConnect
        case let .bidaliPayment(config, balance):
            source = Scripts.payment(config: config, balance: balance)
        }

        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}

struct Scripts {
    static let selection = """
    var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}textarea,input{user-select:text;-webkit-user-select:text;}';
    var head = document.head || document.getElementsByTagName('head')[0];
    var style = document.createElement('style');
    style.type = 'text/css';
    style.appendChild(document.createTextNode(css));
    head.appendChild(style);
    """

    static let navigation = """
    !function(t){
        function e(t){
            setTimeout(function(){
                window.webkit.messageHandlers.navigation.postMessage(t)
            },0)
        }
        function n(n){
            return function(){
                return e("other"), n.apply(t, arguments)
            }
        }
        t.pushState = n(t.pushState)
        t.replaceState = n(t.replaceState)
        window.addEventListener("popstate", function(){
            e("backforward")
        })
    }(window.history);
    """

    static let peraConnect = """
    function setupPeraConnectObserver(){
        const e = new MutationObserver(() => {
            const t = document.getElementById("pera-wallet-connect-modal-wrapper"),
                  e = document.getElementById("pera-wallet-redirect-modal-wrapper");
            if(e && e.remove(), t){
                const o = t.getElementsByTagName("pera-wallet-connect-modal");
                let e = "";
                if(o && o[0] && o[0].shadowRoot){
                    const a = o[0].shadowRoot
                        .querySelector("pera-wallet-modal-touch-screen-mode")
                        .shadowRoot
                        .querySelector("#pera-wallet-connect-modal-touch-screen-mode-launch-pera-wallet-button");
                    alert("LINK_ELEMENT_V1" + a);
                    a && (e = a.getAttribute("href"));
                } else {
                    const r = t.getElementsByClassName("pera-wallet-connect-modal-touch-screen-mode__launch-pera-wallet-button");
                    alert("LINK_ELEMENT_V0" + r);
                    r && (e = r[0].getAttribute("href"));
                }
                alert("WC_URI " + e);
                e && (
                    window.webkit.messageHandlers.\(DiscoverInAppBrowserScriptMessage.peraconnect.rawValue).postMessage(e),
                    alert("Message sent to App" + e)
                );
                t.remove();
            }
        });
        e.disconnect();
        e.observe(document.body, { childList: true, subtree: true });
    }
    setupPeraConnectObserver();
    """

    static func payment(config: BidaliConfig, balance: String) -> String {
        return """
        window.bidaliProvider = {
            key: '\(config.key)',
            name: '\(config.name)',
            paymentCurrencies: \(config.supportedCurrencyProtocols),
            balances: \(balance),
            onPaymentRequest: (paymentRequest) => {
                var payload = { data: paymentRequest };
                window.webkit.messageHandlers.\(BidaliDappDetailScriptMessage.paymentRequest.rawValue).postMessage(JSON.stringify(payload));
            },
            openUrl: function (url) {
                var payload = { data: { url } };
                window.webkit.messageHandlers.\(BidaliDappDetailScriptMessage.openURLRequest.rawValue).postMessage(JSON.stringify(payload));
            }
        };
        true;
        """
    }
}
