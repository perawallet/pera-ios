// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CancellableTasksManager.swift

import Foundation

actor CancellableTasksManager {
    
    // MARK: - Properties
    
    private var tasks: [UUID: CancellableTask] = [:]
    
    // MARK: - Actions
    
    func add<Result, TaskError: Error>(task: Task<Result, TaskError>) -> UUID {
        let uuid = UUID()
        tasks[uuid] = CancellableTask(task: task)
        return uuid
    }
    
    func cancel(uuid: UUID) {
        tasks[uuid]?.cancel()
        tasks[uuid] = nil
    }
    
    func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
