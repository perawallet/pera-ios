// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  TabBarController+Animation.swift

import UIKit

extension TabBarController {
    func animateCenterButtonAsSelected(_ isSelected: Bool) {
        let centerBarButton = tabBar.barButtons[2].contentView
        let icon = isSelected ? items[2].barButtonItem.selectedIcon : items[2].barButtonItem.icon
        
        UIView.transition(
            with: centerBarButton,
            duration: 0.15,
            options: .transitionCrossDissolve,
            animations: {
                centerBarButton.setImage(icon, for: .normal)
                centerBarButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 0.2,
                    options: [.allowUserInteraction, .curveEaseOut],
                    animations: {
                        centerBarButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    },
                    completion: nil
                )
            }
        )
    }
}
