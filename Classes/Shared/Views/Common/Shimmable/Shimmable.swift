// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Shimmable.swift

import UIKit
import MacaroonUIKit

protocol Shimmable: UIView {
    var isShimmering: Bool { get }
    
    var configuration: ShimmerConfiguration { get }

    func startShimmer()
    func stopShimmer()

    func makeShimmerLayer() -> CAGradientLayer
    func makeAnimation() -> CABasicAnimation
}

extension Shimmable {
    func startShimmer() {
        if isShimmering {
            return
        }

        layoutIfNeeded()

        let gradientLayer = makeShimmerLayer()
        layer.mask = gradientLayer

        let animation = makeAnimation()
        gradientLayer.add(animation, forKey: animation.keyPath)
    }

    func stopShimmer() {
        if !isShimmering {
            return
        }

        layer.mask = nil
    }

    func restartShimmer() {
        stopShimmer()
        startShimmer()
    }

    var isShimmering: Bool {
        layer.mask != nil
    }
}

extension Shimmable {
    func makeShimmerLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = configuration.startPoint
        gradientLayer.endPoint = configuration.endPoint
        gradientLayer.locations = configuration.locations
        gradientLayer.colors = configuration.colors
        return gradientLayer
    }

    func makeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(
            keyPath: configuration.keyPath
        )
        animation.fromValue = configuration.fromValue
        animation.toValue = configuration.toValue
        animation.repeatCount = configuration.repeatCount
        animation.duration = configuration.duration
        return animation
    }
}
