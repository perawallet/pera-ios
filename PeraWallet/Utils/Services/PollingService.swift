// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   PollingService.swift

actor PollingService {
    
    // MARK: - Properties
    
    private let timeInterval: Duration
    private var task: Task<Void, Never>?
    
    // MARK: - Initialisers
    
    init(timeInterval: Duration) {
        self.timeInterval = timeInterval
    }
    
    // MARK: - Actions
    
    func start(action: @escaping () async -> Void) {
        
        stop()
        
        task = Task {
            while !Task.isCancelled {
                await action()
                try? await Task.sleep(for: timeInterval)
            }
        }
    }
    
    func stop() {
        task?.cancel()
        task = nil
    }
    
    // MARK: - Deinitialiser
    
    nonisolated deinit {
        task?.cancel()
    }
}
