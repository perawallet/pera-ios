// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol AppDependencies: AnyObject {
    func invalidate()
    func reset()
}
