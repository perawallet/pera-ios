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

//
//   GradientView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils

final class ShimmeringView:
    MacaroonUIKit.BaseView,
    Shimmable,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    override var isHidden: Bool {
        didSet {
            guard oldValue != isHidden else {
                return
            }

            isHidden ? stopShimmer() : startShimmer()
        }
    }

    let configuration: ShimmerConfiguration

    init(
        configuration: ShimmerConfiguration = ShimmerConfiguration()
    ) {
        self.configuration = configuration
        super.init(frame: .zero)

        backgroundColor = AppColors.Shared.Layer.gray.uiColor

        observe(notification: UIApplication.willEnterForegroundNotification) {
            [weak self] _ in
            self?.restartShimmer()
        }
    }
}
