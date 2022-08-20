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

//   ASAAboutScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASAAboutScreen:
    BaseScrollViewController,
    ASADetailPageFragmentScreen,
    UIScrollViewDelegate {
    var isScrollAnchoredOnTop = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let contextView = UIView()
        contextView.backgroundColor = .purple

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.fitToHeight(1500)
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIWhenViewDidLayoutSubviews()
    }
}

/// <mark>
/// UIScrollViewDelegate
extension ASAAboutScreen {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUIWhenViewDidScroll()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateUIWhenViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}

extension ASAAboutScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateScrollWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenViewDidScroll() {
        updateScrollWhenViewDidScroll()
    }

    private func updateUIWhenViewWillEndDragging(
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        updateScrollWhenViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }
}
