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

//   ASAMoreDetailScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASAMoreDetailScreen: PageContainer {
    var activeScrollView: UIScrollView {
        if selectedScreen === aboutFragmentScreen {
            return aboutFragmentScreen.scrollView
        } else {
            return activitiesFragmentScreen.scrollView
        }
    }

    private lazy var activitiesFragmentScreen = ASAActivitiesScreen(configuration: configuration)
    private lazy var aboutFragmentScreen = ASAAboutScreen(configuration: configuration)

    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            ActivitiesPageBarItem(screen: activitiesFragmentScreen),
            AboutPageBarItem(screen: aboutFragmentScreen)
        ]
    }
}

extension ASAMoreDetailScreen {
    func setPagesScrollEnabled(_ enabled: Bool) {
        activitiesFragmentScreen.isScrollEnabled = enabled
        aboutFragmentScreen.isScrollEnabled = enabled
    }

    func addTarget(
        _ target: Any,
        action: Selector
    ) {
        activitiesFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            target,
            action: action
        )
        aboutFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            target,
            action: action
        )
    }
}

extension ASAMoreDetailScreen {
    struct ActivitiesPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = PageBarItemID.activities.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "Activity")
            self.screen = screen
        }
    }

    struct AboutPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = PageBarItemID.about.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: "About")
            self.screen = screen
        }
    }

    enum PageBarItemID: String {
        case activities
        case about
    }
}
