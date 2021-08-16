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
//   CustomIntensityVisualEffectView.swift

import UIKit

 final class CustomIntensityVisualEffectView: UIVisualEffectView {
     private let theEffect: UIVisualEffect
     private let customIntensity: CGFloat
     private var animator: UIViewPropertyAnimator?

     init(effect: UIVisualEffect, intensity: CGFloat) {
         theEffect = effect
         customIntensity = intensity
         super.init(effect: nil)
     }

     required init?(coder aDecoder: NSCoder) { nil }

     deinit {
         animator?.stopAnimation(true)
     }

     override func draw(_ rect: CGRect) {
         super.draw(rect)
         effect = nil
         animator?.stopAnimation(true)
         animator = UIViewPropertyAnimator(duration: 2, curve: .linear) { [unowned self] in
             self.effect = theEffect
         }
         animator?.fractionComplete = customIntensity
     }
 }
