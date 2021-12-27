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
//   TabBarModalViewController.swift

import MacaroonUIKit
import UIKit
import SnapKit

final class TabBarModalViewController: BaseViewController {
    weak var delegate: TabBarModalViewControllerDelegate?

    private lazy var chromeView = UIView()
    private lazy var containerView = TabBarModalView()
    private lazy var theme = Theme()

    private var containerViewBottomConstraint: Constraint?

    override func setListeners() {
        containerView.sendButton.addTarget(self, action: #selector(notifyDelegateToSend), for: .touchUpInside)
        containerView.receiveButton.addTarget(self, action: #selector(notifyDelegateToReceive), for: .touchUpInside)
    }

    override func prepareLayout() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addChrome(theme)
        addContainerView(theme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateView()
    }
}

extension TabBarModalViewController {
    private func addChrome(_ theme: Theme) {
        chromeView.customizeAppearance(theme.chromeStyle)
        chromeView.alpha = .zero

        view.addSubview(chromeView)
        chromeView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addContainerView(_ theme: Theme) {
        containerView.customize(theme.tabBarModalViewTheme)

        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.fitToHeight(theme.modalHeight)
            $0.leading.trailing.equalToSuperview()
            containerViewBottomConstraint = $0.bottom.equalToSuperview().offset(theme.modalHeight).constraint
        }
    }
}

extension TabBarModalViewController {
    private func animateView() {
        animateChromeView()
        animateContainerView()
    }

    private func animateChromeView() {
        updateChromeViewVisibility(to: 1)
    }

    private func animateContainerView() {
        updateContainerViewBottomConstraint(to: .zero)
    }

    func dismissWithAnimation(completion: @escaping () -> Void) {
        updateChromeViewVisibility(to: .zero) {
            self.dismiss(animated: false, completion: completion)
        }
        updateContainerViewBottomConstraint(to: theme.modalHeight)
    }

    private func updateChromeViewVisibility(to alpha: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2) {
            self.chromeView.alpha = alpha
        } completion: { _ in
           completion?()
        }
    }

    private func updateContainerViewBottomConstraint(to value: LayoutMetric) {
        UIView.animate(withDuration: 0.1) {
            self.containerViewBottomConstraint?.update(offset: value)
            self.view.layoutIfNeeded()
        }
    }
}

extension TabBarModalViewController {
    @objc
    private func notifyDelegateToSend() {
        delegate?.tabBarModalViewControllerDidSend(self)
    }

    @objc
    private func notifyDelegateToReceive() {
        delegate?.tabBarModalViewControllerDidReceive(self)
    }
}

protocol TabBarModalViewControllerDelegate: AnyObject {
    func tabBarModalViewControllerDidSend(_ tabBarModalViewController: TabBarModalViewController)
    func tabBarModalViewControllerDidReceive(_ tabBarModalViewController: TabBarModalViewController)
}
