//
//  BaseControl.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class BaseControl: UIControl {
    override var isEnabled: Bool {
        didSet {
            changeAppearance()
        }
    }
    override var isSelected: Bool {
        didSet {
            changeAppearance()
        }
    }
    override var isHighlighted: Bool {
        didSet {
            changeAppearance()
        }
    }

    // MARK: Initialization
    init() {
        super.init(frame: .zero)
        setupAccessibility()
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAccessibility() {
        accessibilityIdentifier = String(describing: self)
        isAccessibilityElement = true
    }

    func reconfigureAppearance(for state: State) { }
    func reconfigureAppearance(for touchState: ControlTouchState) { }

    func configureAppearance() {
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }

    func prepareForReuse() { }
    
    @available(iOS 12.0, *)
    func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        reconfigureAppearance(for: .began)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        reconfigureAppearance(for: .began)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        reconfigureAppearance(for: .ended)
    }

    override func cancelTracking(with event: UIEvent?) {
        reconfigureAppearance(for: .ended)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                preferredUserInterfaceStyleDidChange(to: traitCollection.userInterfaceStyle)
            }
        }
    }
}

extension BaseControl {
    private func changeAppearance() {
        if isEnabled {
            if isSelected {
                reconfigureAppearance(for: .selected)
            } else if isHighlighted {
                reconfigureAppearance(for: .highlighted)
            } else {
                reconfigureAppearance(for: .normal)
            }
        } else {
            reconfigureAppearance(for: .disabled)
        }
    }
}

enum ControlTouchState {
    case began
    case ended
}
