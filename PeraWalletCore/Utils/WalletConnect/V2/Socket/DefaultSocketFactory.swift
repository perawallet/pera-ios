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

//   DefaultSocketFactory.swift

import Foundation
import Starscream
import WalletConnectRelay

struct DefaultSocketFactory: WebSocketFactory {
    func create(with url: URL) -> WebSocketConnecting {
        let request = URLRequest(url: url)
        return WebSocketWrapper(webSocket: WebSocket(request: request))
    }
}

class WebSocketWrapper {
    var webSocket: WebSocket;
    
    var connected = false
    
    init(webSocket: WebSocket) {
        self.webSocket = webSocket
    }
}

extension WebSocketWrapper: WebSocketConnecting {
    
    public var isConnected: Bool {
        get {
            connected
        }
    }
    
    public var onConnect: (() -> Void)? {
        get {
            nil
        }
        set {}
    }
    
    public var onDisconnect: ((Error?) -> Void)? {
        get {
            nil
        }
        set {}
    }
    
    public var onText: ((String) -> Void)? {
        get {
            nil
        }
        set {}
    }
    
    public var request: URLRequest {
        get {
            return webSocket.request
        }
        set {}
    }
    
    public func connect() {
        webSocket.connect()
        self.connected = true
    }
    
    public func disconnect() {
        webSocket.disconnect()
        self.connected = false
    }
    
    public func write(string: String, completion: (() -> Void)?) {
        webSocket.write(string: string, completion: completion)
    }
}
