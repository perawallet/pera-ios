// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol ListDataLoader: AnyObject {
    /// <warning>
    /// It should be conformed as a weak variable to prevent retain cycle
    var delegate: ListDataLoaderDelegate? { get set }
    var hasNextList: Bool { get }

    func loadList()
    func loadNextList()
    func reloadList()
    func discardLoadingList()
    func unloadList()
}

extension ListDataLoader {
    public var hasNextList: Bool {
        return false
    }

    public func loadNextList() {}
}

public protocol ListDataLoaderDelegate: AnyObject {
    func listDataLoaderWillLoadList(_ dataLoader: ListDataLoader)
    func listDataLoaderWillLoadNextList(_ dataLoader: ListDataLoader)
    func listDataLoader(_ dataLoader: ListDataLoader, didLoadList modifier: ListModifier)
    func listDataLoader(_ dataLoader: ListDataLoader, didFailToLoadList error: ListError)
    func listDataLoader(_ dataLoader: ListDataLoader, didFailToLoadNextList error: ListError)
    func listDataLoaderDidUnloadList(_ dataLoader: ListDataLoader)
}

extension ListDataLoaderDelegate {
    public func listDataLoaderWillLoadNextList(
        _ dataLoader: ListDataLoader
    ) {}

    public func listDataLoader(
        _ dataLoader: ListDataLoader,
        didFailToLoadNextList error: ListError
    ) {}

    public func listDataLoaderDidUnloadList(
        _ dataLoader: ListDataLoader
    ) {}
}

public struct ListError: Swift.Error {
    public let reason: Reason
    public let userInfo: Any?

    public init(
        reason: Reason,
        userInfo: Any? = nil
    ) {
        self.reason = reason
        self.userInfo = userInfo
    }
}

extension ListError {
    public enum Reason {
        case inapp
        case network
        case fault
    }
}

public enum ListModifier {
    case none
    case update(snapshot: ListSnapshot, applyUpdates: (() -> Void)? = nil)
    case reload
}
