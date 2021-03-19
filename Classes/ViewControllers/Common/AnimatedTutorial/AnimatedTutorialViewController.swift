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
//  AnimatedTutorialViewController.swift

import UIKit

class AnimatedTutorialViewController: BaseScrollViewController {

    private let flow: AccountSetupFlow
    private let tutorial: AnimatedTutorial
    private let isActionable: Bool

    private lazy var animatedTutorialView = AnimatedTutorialView(isActionable: isActionable)

    init(flow: AccountSetupFlow, tutorial: AnimatedTutorial, isActionable: Bool, configuration: ViewControllerConfiguration) {
        self.flow = flow
        self.tutorial = tutorial
        self.isActionable = isActionable
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addInfoBarButtonIfNeeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatedTutorialView.startAnimating(with: LottieConfiguration())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animatedTutorialView.stopAnimating()
    }

    override func configureAppearance() {
        super.configureAppearance()
        setTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        contentView.backgroundColor = Colors.Background.tertiary
        animatedTutorialView.bind(AnimatedTutorialViewModel(tutorial: tutorial))
    }

    override func linkInteractors() {
        super.linkInteractors()
        animatedTutorialView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupAnimatedTutorialViewLayout()
    }
}

extension AnimatedTutorialViewController {
    private func setupAnimatedTutorialViewLayout() {
        contentView.addSubview(animatedTutorialView)
        animatedTutorialView.pinToSuperview()
    }
}

extension AnimatedTutorialViewController {
    private func addInfoBarButtonIfNeeeded() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.openWalletSupport()
        }

        switch tutorial {
        case .recover,
             .backUp,
             .watchAccount:
            rightBarButtonItems = [infoBarButtonItem]
        default:
            break
        }
    }

    private func openWalletSupport() {
        switch tutorial {
        case .backUp:
            if let url = URL(string: "https://algorandwallet.com/support/security/backing-up-your-recovery-passphrase") {
                open(url)
            }
        case .recover:
            if let url = URL(string: "https://algorandwallet.com/support/getting-started/recover-an-algorand-account") {
                open(url)
            }
        case .watchAccount:
            if let url = URL(string: "https://algorandwallet.com/support/general/adding-a-watch-account") {
                open(url)
            }
        default:
            break
        }
    }
}

extension AnimatedTutorialViewController: AnimatedTutorialViewDelegate {
    func animatedTutorialViewDidApproveTutorial(_ animatedTutorialView: AnimatedTutorialView) {
        switch tutorial {
        case .recover:
            open(.accountRecover(flow: flow), by: .push)
        case .watchAccount:
            open(.watchAccountAddition(flow: flow), by: .push)
        default:
            // Will be updated when the flows are updated.
            break
        }
    }

    func animatedTutorialViewDidTakeAction(_ animatedTutorialView: AnimatedTutorialView) {

    }
}

enum AnimatedTutorial {
    case backUp
    case writePassphrase
    case watchAccount
    case recover
    case passcode
    case localAuthentication
}
