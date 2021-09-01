// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol Segment {
    var layout: Button.Layout { get }
    var style: ButtonStyle { get }
}

extension Segment {
    public var layout: Button.Layout {
        return .none
    }
}
