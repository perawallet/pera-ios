// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ListReusable: UIView {
    func prepareForReuse()
}

extension ListReusable {
    public func prepareForReuse() { }
}
