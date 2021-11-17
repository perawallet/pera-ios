// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension NSDirectionalEdgeInsets {
    public init(_ paddings: LayoutPaddings) {
        self.init(
            top: paddings.top,
            leading: paddings.leading,
            bottom: paddings.bottom,
            trailing: paddings.trailing
        )
    }
}
