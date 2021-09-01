// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol NavigationBarLargeTitleConfigurable: Screen & NavigationBarConfigurable {
    associatedtype SomeNavigationBarTitleView: NavigationBarTitleView
    associatedtype SomeNavigationBarLargeTitleView: NavigationBarLargeTitleView

    var navigationBarTitleView: SomeNavigationBarTitleView { get }
    var navigationBarLargeTitleView: SomeNavigationBarLargeTitleView { get }
    var navigationBarScrollView: UIScrollView { get }
}

extension NavigationBarLargeTitleConfigurable where Self: ScrollScreen {
    public var navigationBarScrollView: UIScrollView {
        return scrollView
    }
}

extension NavigationBarLargeTitleConfigurable where Self: ListScreen {
    public var navigationBarScrollView: UIScrollView {
        return listView
    }
}

public protocol NavigationBarTitleView: UIView {
    var title: EditText? { get set }
    var titleAlpha: CGFloat { get set }
}

public protocol NavigationBarLargeTitleView: UIView {
    var title: EditText? { get set }
    var scrollEdgeOffset: CGFloat { get }
}
