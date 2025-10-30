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

//   PeraLogger.swift

import OSLog

public final class PeraLogger: ObservableObject {
    
    public struct Log: Identifiable {
        public let id: UUID
        public let message: String
    }
    
    public static let shared = PeraLogger()
    
    private init() {}
    
    @Published public private(set) var logs: [Log] = []
    
    public func log(message: String) {
        DispatchQueue.main.async {
            Logger(subsystem: "com.pera.debug", category: "debug").log(level: .default, "\(message)")
            guard message.hasPrefix("[DB]") else { return }
            self.logs.append(Log(id: UUID(), message: message))
        }
    }
}
