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

//   ShimmerDisplayable.swift

import UIKit

protocol ShimmerDisplayable {
    var shimmableSubviews: [Shimmable] { get }

    func startSubviewsShimmer()
    func stopSubviewsShimmer()
}

extension ShimmerDisplayable where Self: UIView {
    var shimmableSubviews: [Shimmable] {
        var shimmableViews = [Shimmable]()

        allSubviews.forEach {
            if let subview = $0 as? Shimmable {
                shimmableViews.append(subview)
            }
        }

        return shimmableViews
    }
}

extension ShimmerDisplayable where Self: UIViewController {
    var shimmableSubviews: [Shimmable] {
        var shimmableViews = [Shimmable]()

        view.allSubviews.forEach {
            if let subview = $0 as? Shimmable {
                shimmableViews.append(subview)
            }
        }

        return shimmableViews
    }
}

extension ShimmerDisplayable {
    func startSubviewsShimmer() {
        shimmableSubviews.forEach {
            $0.startShimmer()
        }
    }

    func stopSubviewsShimmer() {
        shimmableSubviews.forEach {
            $0.stopShimmer()
        }
    }

    func restartSubviewsShimmer() {
        stopSubviewsShimmer()
        startSubviewsShimmer()
    }
}

fileprivate extension UIView {
    var allSubviews: [UIView] {
        return subviews.flatMap { [$0] + $0.allSubviews }
    }
}
