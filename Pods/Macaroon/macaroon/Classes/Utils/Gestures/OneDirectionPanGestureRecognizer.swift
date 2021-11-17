// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

open class OneDirectionPanGestureRecognizer: UIPanGestureRecognizer {
    public private(set) var isDragging = false
    public private(set) var lastTranslation = 0

    public let direction: Direction

    public init(
        direction: Direction,
        target: Any?,
        action: Selector?
    ) {
        self.direction = direction

        super.init(
            target: target,
            action: action
        )
    }

    open override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent
    ) {
        super.touchesMoved(
            touches,
            with: event
        )

        if state == .failed {
            return
        }

        guard let touch = touches.first else {
            return
        }

        let touchLocation =
            touch.location(
                in: view
            )
        let previousTouchLocation =
            touch.previousLocation(
                in: view
            )

        lastTranslation += Int(previousTouchLocation.y - touchLocation.y)

        if isDragging {
            return
        }

        if lastTranslation == 0 {
            isDragging = false
            return
        }

        switch direction {
        case .up:
            if lastTranslation < 0 {
                state = .failed
            } else {
                isDragging = true
            }
        case .down:
            if lastTranslation > 0 {
                state = .failed
            } else {
                isDragging = true
            }
        }
    }

    open override func reset() {
        super.reset()

        isDragging = false
        lastTranslation = 0
    }
}

extension OneDirectionPanGestureRecognizer {
    public enum Direction {
        case up
        case down
    }
}
