// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol AppDependenciesResolver: AnyObject {
    associatedtype AppDependencies

    var appDependencies: AppDependencies! { get set }

    static var shared: Self { get }

    func invalidate()
    func reset()
}

extension AppDependenciesResolver {
    public func register(_ appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
    }

    public func register<T>(
        _ appDependency: T,
        for keyPath: WritableKeyPath<AppDependencies, T>
    ) {
        appDependencies[keyPath: keyPath] = appDependency
    }

    public func resolve() -> AppDependencies {
        return appDependencies
    }

    public func resolve<T>(_ keyPath: KeyPath<AppDependencies, T>) -> T {
        return appDependencies[keyPath: keyPath]
    }
}
