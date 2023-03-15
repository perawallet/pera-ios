// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupImportBackupScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupImportBackupScreen:
    BaseScrollViewController,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event, AlgorandSecureBackupImportBackupScreen) -> Void

    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()
    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private lazy var headerView = UILabel()
    private lazy var uploadView = UIView()
    private lazy var actionsView = VStackView()
    private lazy var pasteActionView = MacaroonUIKit.Button()
    private lazy var nextActionView = MacaroonUIKit.Button()

    private lazy var theme: AlgorandSecureBackupImportBackupScreenTheme = .init()

    private var isViewLayoutLoaded = false

    private var encryptedData: Data?

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        navigationBarLargeTitleController.title = theme.navigationTitle
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isViewLayoutLoaded {
            return
        }

        updateUIWhenViewDidLayoutSubviews()

        isViewLayoutLoaded = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addHeader()
        addActions()
        addNextAction()
    }
}

// MARK: UI functions
extension AlgorandSecureBackupImportBackupScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }

    private func addHeader() {
        headerView.customizeAppearance(theme.header)

        contentView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == theme.defaultInset
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
        }
    }

    private func addActions() {
        contentView.addSubview(uploadView)
        uploadView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(theme.uploadTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.height.equalTo(theme.uploadHeight)
        }
        contentView.addSubview(actionsView)
        actionsView.spacing = theme.actionsPadding
        actionsView.snp.makeConstraints {
            $0.top.equalTo(uploadView.snp.bottom).offset(theme.actionsTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.bottom.greaterThanOrEqualToSuperview().inset(theme.defaultInset)
        }
        addPasteAction()
    }

    private func addPasteAction() {
        pasteActionView.customizeAppearance(theme.pasteAction)
        pasteActionView.titleEdgeInsets = theme.pasteActionTitleEdgeInsets

        pasteActionView.addTouch(
            target: self,
            action: #selector(performPasteAction)
        )

        actionsView.addArrangedSubview(pasteActionView)
    }

    private func addNextAction() {
        nextActionView.customizeAppearance(theme.nextAction)
        nextActionView.contentEdgeInsets = theme.nextActionContentEdgeInsets

        footerView.addSubview(nextActionView)
        nextActionView.snp.makeConstraints {
            $0.top == theme.nextActionEdgeInsets.top
            $0.leading == theme.nextActionEdgeInsets.leading
            $0.trailing == theme.nextActionEdgeInsets.trailing
            $0.bottom == theme.nextActionEdgeInsets.bottom
        }

        nextActionView.addTouch(
            target: self,
            action: #selector(performNextAction)
        )
        
        updateNextActionEnable()
    }
}

// MARK: Helpers
extension AlgorandSecureBackupImportBackupScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews() {
        scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    @objc
    private func performPasteAction() {
        guard
            let pasteBoardText = UIPasteboard.general.string,
            let data = Data(base64Encoded: pasteBoardText)
        else {
            return
        }

        encryptedData = data
        performNextAction()
    }

    @objc
    private func performNextAction() {
        guard let encryptedData else { return }
        eventHandler?(.backupImported(encryptedData), self)
    }

    private func updateNextActionEnable() {
        self.nextActionView.isEnabled = self.encryptedData != nil
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    enum Event {
        case backupImported(Data)
    }
}

