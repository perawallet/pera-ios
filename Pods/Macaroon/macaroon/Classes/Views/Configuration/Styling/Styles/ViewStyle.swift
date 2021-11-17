// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public typealias ViewStyle = BaseStyle<ViewStyleAttribute>

extension ViewStyle {
    public var backgroundColor: Color? {
        for attribute in self {
            switch attribute {
            case .backgroundColor(let backgroundColor): return backgroundColor
            default: break
            }
        }

        return nil
    }
}

public enum ViewStyleAttribute: BaseStyleAttribute {
    /// <mark>
    /// Base
    case backgroundColor(Color)
    case tintColor(Color)
}

extension ViewStyleAttribute {
    public var id: String {
        switch self {
        case .backgroundColor: return Self.getBackgroundColorAttributeId()
        case .tintColor: return Self.getTintColorAttributeId()
        }
    }
}
