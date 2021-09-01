// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class HStackView: UIStackView {
    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        axis = .horizontal
        alignment = .fill
        distribution = .fill
        spacing = 0
    }
}

open class VStackView: UIStackView {
    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = 0
    }
}
