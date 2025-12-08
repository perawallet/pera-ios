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

public final class PeraLogger: ObservableObject {

    public struct Log: Identifiable {
        public let id: UUID
        public let message: String
    }
    
    public enum LoggerError: Error {
        case unableToLog(error: Error)
    }
    
    // MARK: - Properties

    public static let shared = PeraLogger()
    
    @Published public private(set) var logs: [Log] = []
    @Published public private(set) var error: LoggerError?
    
    private var loggers: [Loggable] = []
    private var logsStore: LogsStorage?

    // MARK: - Initialisers
    
    private init() {}

    // MARK: - Actions
    
    public func log(message: String) {
        
        let formattedMessage = format(message: message)
        
        Task { @MainActor in
            let log = Log(id: UUID(), message: formattedMessage)
            logs.append(log)
        }
        
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
        try fetchLogs()
    }
    
    public func createLogsFile() throws -> URL? { try logsStore?.createLogsArchive() }
    public func deleteExportedLogsFile() throws { try logsStore?.removeLogsArchive() }
    
    private func fetchLogs() throws {
        
        guard let logsStore else {
            logs = []
            return
        }
        
        logs = try logsStore
            .fetchLogs()
            .map { Log(id: UUID(), message: $0) }
    }
    
    // MARK: - Helpers
    
    private func format(message: String) -> String { "\(Date()) | \(message)" }
}

public enum Log {
    
    public static func log(message: String) {
        PeraLogger.shared.log(message: message)
    }
}
