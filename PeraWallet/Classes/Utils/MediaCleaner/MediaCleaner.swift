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

//   MediaCleaner.swift

import Foundation
import pera_wallet_core

public struct MediaCleaner {
    
    private let analytics: ALGAnalytics
    
    init(analytics: ALGAnalytics) {
        self.analytics = analytics
    }
    
    func performOneTimeMediaCleanup() {
        let isMediaCleanupCompleted = PeraUserDefaults.isMediaCleanupCompleted ?? false
        
        guard !isMediaCleanupCompleted else {
            return
        }

        cleanupTemporaryMediaFiles()
        
        PeraUserDefaults.isMediaCleanupCompleted = true
    }
}

private extension MediaCleaner {
    func cleanupTemporaryMediaFiles() {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil, options: [])
            
            let mediaExtensions = MediaExtension.allCases.map { $0.rawValue.lowercased() }
            
            for fileURL in contents {
                let fileExtension = fileURL.pathExtension.lowercased()
                let fileExtensionWithDot = "." + fileExtension
 
                if mediaExtensions.contains(fileExtensionWithDot) {
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    if let creationDate = attributes[.creationDate] as? Date {
                        let oneHourAgo = Date().addingTimeInterval(-3600)
                        
                        if creationDate < oneHourAgo {
                            try fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            }
        } catch {
            analytics.record(
                .mediaCleanUpError()
            )
        }
    }
}
