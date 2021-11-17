//
//  TaskStorage.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 4.04.2019.
//

import Foundation

struct TaskStorage {
    private typealias Table = [String: [TaskConvertible]]

    /// <note> AtomicWrapper is for preventing race-conditions.
    private var tableWrapper = AtomicWrapper<Table>(value: [:])
}

extension TaskStorage {
    func add(_ task: TaskConvertible, for endpoint: Endpoint) {
        add(task, for: endpoint.request.path)
    }

    func add(_ task: TaskConvertible, for path: String) {
        tableWrapper.setValue { table in
            if !task.inProgress { return }

            if var currentTasks = table[path] {
                currentTasks.append(task)
                table[path] = currentTasks
            } else {
                table[path] = [task]
            }
        }
    }
}

extension TaskStorage {
    func delete(for endpoint: Endpoint) {
        if let task = endpoint.task {
            delete(task, with: endpoint.request.path)
        }
    }

    func cancelAndDelete(for endpoint: Endpoint) {
        if let task = endpoint.task {
            cancelAndDelete(task, with: endpoint.request.path)
        }
    }

    func delete(_ task: TaskConvertible, with path: String) {
        delete(task, with: path, afterCancellation: false)
    }

    func cancelAndDelete(_ task: TaskConvertible, with path: String) {
        delete(task, with: path, afterCancellation: true)
    }

    func deleteAll(with path: String) {
        deleteAll(with: path, afterCancellation: false)
    }

    func cancelAndDeleteAll(with path: String) {
        deleteAll(with: path, afterCancellation: true)
    }

    func deleteAll(relativeTo path: String) {
        deleteAll(relativeTo: path, afterCancellation: false)
    }

    func cancelAndDeleteAll(relativeTo path: String) {
        deleteAll(relativeTo: path, afterCancellation: true)
    }

    func deleteAll() {
        deleteAll(afterCancellation: false)
    }

    func cancelAndDeleteAll() {
        deleteAll(afterCancellation: true)
    }
}

extension TaskStorage {
    private func delete(_ task: TaskConvertible, with path: String, afterCancellation: Bool) {
        if afterCancellation {
            task.cancelNow()
        }
        tableWrapper.setValue { table in
            guard var currentTasks = table[path] else { return }

            currentTasks.removeAll { $0.taskIdentifier == task.taskIdentifier }

            if currentTasks.isEmpty {
                table[path] = nil
            } else {
                table[path] = currentTasks
            }
        }
    }

    private func deleteAll(with path: String, afterCancellation: Bool) {
        tableWrapper.setValue { table in
            if afterCancellation {
                table[path]?.forEach { $0.cancelNow() }
            }
            table[path] = nil
        }
    }

    private func deleteAll(relativeTo path: String, afterCancellation: Bool) {
        tableWrapper.setValue { table in
            for item in table where item.key.contains(path) {
                if afterCancellation {
                    item.value.forEach { $0.cancelNow() }
                }
                table[item.key] = nil
            }
        }
    }

    private func deleteAll(afterCancellation: Bool) {
        tableWrapper.setValue { table in
            if afterCancellation {
                table.forEach { $1.forEach { $0.cancelNow() } }
            }
            table.removeAll()
        }
    }
}

extension TaskStorage: Printable {
    /// <mark> CustomStringConvertible
    var description: String {
        return """
        {
          \(tableWrapper.getValue()
            .map({ "\($0.key):[\($0.value.map({ $0.description }).joined(separator: ", "))]" })
            .joined(separator: "\n  ")
          )
        }
        """
    }
    /// <mark> CustomDebugStringConvertible
    var debugDescription: String {
        return """
        {
          \(tableWrapper.getValue()
            .map({ "\($0.key):[\n\t\($0.value.map({ $0.debugDescription }).joined(separator: ",\n\t"))]" })
            .joined(separator: "\n  ")
          )
        }
        """
    }
}
