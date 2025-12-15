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

public protocol Loggable {
    func log(message: String) throws
}

public protocol LogsStorage: Loggable {
    func fetchLogs() throws -> [String]
    func createLogsArchive() throws -> URL
    func removeLogsArchive() throws
}

public actor PeraLogger: ObservableObject {
    
    public enum LoggerError: Error {
        case unableToLog(error: Error)
    }
    
    // MARK: - Properties

    public static let shared = PeraLogger()
    
    @Published public private(set) var error: LoggerError?
    
    private var loggers: [Loggable] = []
    private var logsStore: LogsStorage?

    // MARK: - Initialisers
    
    private init() {}

    // MARK: - Actions
    
    public func log(message: String) {
        
        let formattedMessage = format(message: message)
        
        loggers.forEach {
            do {
                try $0.log(message: formattedMessage)
            } catch {
                self.error = .unableToLog(error: error)
            }
        }
    }
    
    public func update(loggers: [Loggable], logsStore: LogsStorage?) throws {
        self.loggers = loggers
        self.logsStore = logsStore
    }
    
    public func createLogsFile() throws -> URL? {
        try logsStore?.createLogsArchive()
    }
    public func deleteExportedLogsFile() throws { try logsStore?.removeLogsArchive() }
    
    // MARK: - Helpers
    
    private func format(message: String) -> String { "\(Date()) | \(message)" }
}

public enum Log {
    
    public static func log(message: String) {
        Task {
            await PeraLogger.shared.log(message: message)
        }
    }
}
