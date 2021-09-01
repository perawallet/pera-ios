// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class ToggleButton: BaseControl {
    open var indicator: ImageSet? {
        didSet { recustomizeAppearanceWhenStateDidChange() }
    }

    private lazy var imageView = UIImageView()

    public init() {
        super.init(
            frame: .zero
        )

        customizeAppearance()
        prepareLayout()
    }

    open override func recustomizeAppearance(
        for state: UIControl.State
    ) {
        switch state {
        case .selected: imageView.image = indicator?.selected
        case .disabled: imageView.image = indicator?.disabled ?? indicator?.image
        default: imageView.image = indicator?.image
        }
    }
}

extension ToggleButton {
    public func toggle() {
        if !isEnabled {
            return
        }

        isSelected.toggle()
    }
}

extension ToggleButton {
    private func customizeAppearance() {
        imageView.contentMode = .center
    }

    private func prepareLayout() {
        addSubview(
            imageView
        )
        imageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}
