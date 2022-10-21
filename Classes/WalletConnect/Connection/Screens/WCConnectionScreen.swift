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

//   WCConnectionScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class WCConnectionScreen: BaseViewController, BottomSheetPresentable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    let walletConnectSession: WalletConnectSession
    
    var modalHeight: ModalHeight = .compressed
    
    private let theme = WCConnectionScreenTheme()
    
    private(set) lazy var contextView = WCConnectionView()
    private(set) lazy var bottomContainerView = EffectView()
    private lazy var actionsStackView = UIStackView()
    private lazy var cancelActionView = MacaroonUIKit.Button()
    private lazy var connectActionView = MacaroonUIKit.Button()
    
    private let walletConnectSessionConnectionCompletionHandler: WalletConnectSessionConnectionCompletionHandler
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    init(
        walletConnectSession: WalletConnectSession,
        walletConnectSessionConnectionCompletionHandler: @escaping WalletConnectSessionConnectionCompletionHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.walletConnectSession = walletConnectSession
        self.walletConnectSessionConnectionCompletionHandler = walletConnectSessionConnectionCompletionHandler
        super.init(configuration: configuration)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addBackground()
        addContext()
        addBottomContainer()
    }
}

extension WCConnectionScreen {
    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    private func addContext() {
        contextView.customize(theme.contextView)
        
        view.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom == view.safeAreaBottom
        }
    }
    
    private func addBottomContainer() {
        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        bottomContainerView.effect = LinearGradientEffect(gradient: backgroundGradient)

        view.addSubview(bottomContainerView)
        bottomContainerView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == view.safeAreaBottom
            $0.trailing == 0
        }
        
        addActions()
    }
    
    private func addActions() {
        actionsStackView.distribution = .fillEqually
        actionsStackView.axis = .horizontal
        actionsStackView.spacing = theme.actionsStackViewSpacing
        
        addCancelAction()
        addConnectAction()
        
        bottomContainerView.addSubview(actionsStackView)
        actionsStackView.snp.makeConstraints {
            $0.leading.trailing == theme.actionsHorizontalPadding
            $0.bottom.top == theme.actionsVerticalPadding
        }
    }
    
    private func addCancelAction() {
        cancelActionView.customizeAppearance(theme.cancelAction)
        cancelActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionsStackView.addArrangedSubview(cancelActionView)
        
        cancelActionView.addTouch(
            target: self,
            action: #selector(performCancel)
        )
    }
    
    private func addConnectAction() {
        connectActionView.customizeAppearance(theme.connectAction)
        connectActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionsStackView.addArrangedSubview(connectActionView)
        
        connectActionView.addTouch(
            target: self,
            action: #selector(performConnect)
        )
    }
}

extension WCConnectionScreen {
    private func bindUIData() {
        contextView.startObserving(event: .openUrl) {
            [unowned self] in
            
            self.open(walletConnectSession.dAppInfo.peerMeta.url)
        }
    }
    
    private func updateUILayout() {
        performLayoutUpdates(animated: self.isViewAppeared)
    }
}

extension WCConnectionScreen {
    @objc
    private func performCancel() {}
    
    @objc
    private func performConnect() {}
}

extension WCConnectionScreen {
    enum Event {
        case performCancel
        case performConnect
    }
}
