// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

/// <note>
/// Identifies a single screen.
public protocol Path: Equatable {
    typealias ScreenBuilder = () -> ScreenRoutable

    /// <note>
    /// It should be unique for every path out there.
    var identifier: String { get }
    var build: ScreenBuilder { get }

    static func instance(_ identifier: String) -> Self
}

extension Path {
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

/// <note>
/// Identifies a pre-defined path in a flow.
public enum ExistingPath {
    case initial
    /// <note>
    /// Shows the visible path
    case last
    case interim(ScreenRoutable)
}
