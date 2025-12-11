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

//   FileLogger.swift

import pera_wallet_core
import UIKit
import Combine

final class FileLogger: LogsStorage {
    
    enum LoggerError: Error {
        case unableToConvertLogMessageToData
        case unableToConvertDataToLogMessage
        case unableToCreateLogsFile(error: Error)
        case unableToUpdateLogsFile(error: Error)
        case unableToResoreMessagesFromLogsFile(error: Error)
        case unableToCreateArchive(error: Error)
        case unableToDeleteArchive(error: Error)
        case unableToRemoveObsoleteLogs(error: Error)
    }
    
    // MARK: - Constants
    
    private let separator: Character = "\n"
    private let fileSuffix = "logs.txt"
    private let archiveFilename = "logs.zip"
    private let maxFileAge: TimeInterval = 60 * 60 * 24 * 7
    
    // MARK: - Properties
    
    private var fileURL: URL {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let formattedComponents: [String] = [components.year, components.month, components.day]
            .compactMap { $0 }
            .map { String(format: "%02d", $0) }
        let filename = (formattedComponents + [fileSuffix]).joined(separator: "-")
        let result = directoryURL.appendingPathComponent(filename)
        return result
    }
    
    private let directoryURL: URL
    
    private var archiveURL: URL { FileManager.default.temporaryDirectory.appendingPathComponent(archiveFilename) }
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(directoryURL: URL) throws(LoggerError) {
        self.directoryURL = directoryURL
        try createFolderIfNeeded()
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupCallbacks() {
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in try? self?.removeOldLogs() }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions - LogsStorage
    
    func log(message: String) throws {
        try appendLogLineToFile(message: message)
    }
    
    func fetchLogs() throws -> [String] {
        try fetchLogsFromFiles()
    }
    
    // MARK: - Actions - LogsStorage
    
    func createLogsArchive() throws -> URL {
        
        try removeLogsArchive()
        
        do {
            try FileArchiver.archive(inputURL: directoryURL, outputURL: archiveURL)
        } catch {
            throw LoggerError.unableToCreateArchive(error: error)
        }
        
        return archiveURL
    }
    
    func removeLogsArchive() throws {
        
        guard FileManager.default.fileExists(atPath: archiveURL.path) else { return }
        
        do {
            try FileManager.default.removeItem(at: archiveURL)
        } catch {
            throw LoggerError.unableToDeleteArchive(error: error)
        }
    }
    
    // MARK: - Actions
    
    private func createFolderIfNeeded() throws(LoggerError) {
        
        guard !FileManager.default.fileExists(atPath: directoryURL.path) else { return }
        
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw .unableToCreateLogsFile(error: error)
        }
    }
    
    private func createLogFileIfNeeded() {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
    }
    
    private func appendLogLineToFile(message: String) throws(LoggerError) {
        
        let formattedMessage = message + String(separator)
        guard let logData = formattedMessage.data(using: .utf8) else { throw .unableToConvertLogMessageToData }
        
        createLogFileIfNeeded()
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            try fileHandle.seekToEnd()
            fileHandle.write(logData)
            try fileHandle.close()
        } catch {
            throw .unableToUpdateLogsFile(error: error)
        }
    }
    
    private func fetchLogsFromFiles() throws(LoggerError) -> [String] {
        
        let filesURLs: [URL]
        
        do {
            filesURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            throw .unableToResoreMessagesFromLogsFile(error: error)
        }
        
        do {
            return try filesURLs
                .sorted { $0.path < $1.path }
                .flatMap { try fetchLogsFromFile(url: $0) }
        } catch let error as LoggerError {
            throw error
        } catch {
            throw .unableToResoreMessagesFromLogsFile(error: error)
        }
    }
    
    private func fetchLogsFromFile(url: URL) throws(LoggerError) -> [String] {
        
        let data: Data
        
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw .unableToResoreMessagesFromLogsFile(error: error)
        }
        
        guard let contents = String(data: data, encoding: .utf8) else { throw .unableToConvertDataToLogMessage }
        
        return contents
            .split(separator: separator, omittingEmptySubsequences: true)
            .map { String($0) }
    }
    
    private func removeOldLogs() throws(LoggerError) {
        
        let filesURLs: [URL]
        
        do {
            filesURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        } catch {
            throw .unableToRemoveObsoleteLogs(error: error)
        }
        
        do {
            try filesURLs
                .filter {
                    let values = try $0.resourceValues(forKeys: [.creationDateKey])
                    guard let creationDate = values.creationDate else { return true }
                    return creationDate < Date(timeIntervalSinceNow: -maxFileAge)
                }
                .forEach { try FileManager.default.removeItem(at: $0) }
        } catch {
            throw .unableToRemoveObsoleteLogs(error: error)
        }
    }
}
