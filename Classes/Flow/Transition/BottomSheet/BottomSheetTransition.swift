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
//   BottomSheetTransition.swift

import Foundation
import Macaroon
import UIKit

final class BottomSheetTransition {
    private(set) var transitionController: BottomSheetTransitionController?

    unowned let presentingViewController: UIViewController

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
}

extension BottomSheetTransition {
    func perform(_ screen: Screen, completion: (() -> Void)? = nil) {
        let transitionController =
            BottomSheetTransitionController(
                presentingViewController: presentingViewController
            ) { [weak self] in

                guard let self = self else {
                    return
                }

                completion?()

                self.transitionController = nil
            }
        
        presentingViewController.open(
            screen,
            by: .customPresent(presentationStyle: .custom, transitionStyle: .coverVertical, transitioningDelegate: transitionController),
            animated: true
        )

        self.transitionController = transitionController
    }
}

extension BottomSheetPresentable where Self: ScrollScreen {
    var presentedScrollView: UIScrollView? {
        return scrollView
    }
}

extension BottomSheetPresentable where Self: ListScreen {
    var presentedScrollView: UIScrollView? {
        return listView
    }
}
