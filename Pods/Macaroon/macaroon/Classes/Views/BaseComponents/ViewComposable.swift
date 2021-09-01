// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ViewComposable: UIView {
    associatedtype StyleSheet
    associatedtype LayoutSheet

    func customizeAppearance(_ styleSheet: StyleSheet)
    func prepareLayout(_ layoutSheet: LayoutSheet)
    func setListeners()
    func linkInteractors()
}

extension ViewComposable {
    public func setListeners() {}
    public func linkInteractors() {}
}
