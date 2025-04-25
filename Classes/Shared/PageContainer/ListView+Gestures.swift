// Copyright 2025 Pera Wallet, Lda

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ListView+Gestures.swift

import MacaroonUIKit
import UIKit

protocol ListViewTouchInteractable: UIView {
    func shouldCancelListViewGesture(atPoint point: CGPoint) -> Bool
}

extension ListView: @retroactive UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = otherGestureRecognizer.view as? ListViewTouchInteractable else { return false }
        let point = otherGestureRecognizer.location(in: view)
        return view.shouldCancelListViewGesture(atPoint: point)
    }
}
