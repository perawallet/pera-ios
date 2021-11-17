// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol ViewModel {}

public protocol PairedViewModel {
    associatedtype PairedModel

    init(_ model: PairedModel)
}

public protocol BindableViewModel: ViewModel {
    init<T>(_ model: T)
    /// <todo>
    /// Can bind a nil model??? Maybe a reset() method.
    mutating func bind<T>(_ model: T)
}
