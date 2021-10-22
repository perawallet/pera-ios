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

import Macaroon
import UIKit

final class TabBarModalViewController: BaseViewController {
    weak var delegate: TabBarModalViewControllerDelegate?

    private lazy var chromeView = UIView()
    private lazy var tabBarModalView = TabBarModalView()
    private lazy var theme = Theme()
    
    override func setListeners() {
        tabBarModalView.sendButton.addTarget(self, action: #selector(notifyDelegateToSend), for: .touchUpInside)
        tabBarModalView.receiveButton.addTarget(self, action: #selector(notifyDelegateToReceive), for: .touchUpInside)
    }

    override func prepareLayout() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addChrome(theme)
        addTabBarModal(theme)
    }
}

extension TabBarModalViewController {
    func addChrome(_ theme: Theme) {
        chromeView.customizeAppearance(theme.chromeStyle)

        view.addSubview(chromeView)
        chromeView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    func addTabBarModal(_ theme: Theme) {
        tabBarModalView.customize(theme.tabBarModalViewTheme)

        view.addSubview(tabBarModalView)
        tabBarModalView.snp.makeConstraints {
            $0.fitToHeight(theme.modalHeight)
            $0.bottom.leading.trailing.equalToSuperview()
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
