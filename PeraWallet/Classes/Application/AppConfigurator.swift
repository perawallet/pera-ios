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

//   AppConfigurator.swift

import pera_wallet_core

enum AppConfigurator {
    
    enum ConfigError: Error {
        case unableToGetLogsFilePath
        case unableToCreateLogger(error: Error)
        case unableToUpdateLoggersConfiguration(error: Error)
    }
    
    // MARK: - Constants
    
    private static let subsystem = "com.peralda.perawallet.logs"
    
    // MARK: - Properties
    
    private static var logsDirectoryURL: URL {
        get throws(ConfigError) {
            guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { throw .unableToGetLogsFilePath }
            return url.appendingPathComponent(subsystem, isDirectory: true)
        }
    }
    
    // MARK: - Actions
    
    static func configure() throws(ConfigError) {
        try setupLogging()
    }
    
    // MARK: - Setups
    
    private static func setupLogging() throws(ConfigError) {
        
        let logsDirectoryURL = try logsDirectoryURL
        
        let terminalLogger = TerminalLogger(subsystem: subsystem)
        let fileLogger: FileLogger
        
        do {
            fileLogger = try FileLogger(directoryURL: logsDirectoryURL)
        } catch {
            throw .unableToCreateLogger(error: error)
        }
        
        do {
            try PeraLogger.shared.update(loggers: [terminalLogger, fileLogger], logsStore: fileLogger)
        } catch {
            throw .unableToUpdateLoggersConfiguration(error: error)
        }
    }
}
