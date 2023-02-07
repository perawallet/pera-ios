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

//   AlgorandSecureBackupInstructionScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupInstructionScreen:
    ScrollScreen,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event) -> Void

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

    private lazy var contextView = UIView()
    private lazy var headerView = UILabel()
    private lazy var instructionsView = VStackView()
    private lazy var startActionView = MacaroonUIKit.Button()

    private let theme: AlgorandSecureBackupInstructionScreenTheme

    init(theme: AlgorandSecureBackupInstructionScreenTheme = .init()) {
        self.theme = theme
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationBarLargeTitleController.title = "algorand-secure-backup-instruction-title".localized

        let offset = theme.contextPaddings.top - theme.navigationBarEdgeInset.top
        navigationBarLargeTitleController.additionalScrollEdgeOffset = offset
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
        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addContext()
        addStartAction()
    }
}

extension AlgorandSecureBackupInstructionScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        contentView.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == navigationBarLargeTitleView.snp.bottom + theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addHeader()
        addInstructions()
    }

    private func addHeader() {
        headerView.customizeAppearance(theme.header)

        contextView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindHeader()
    }

    private func addInstructions() {
        contextView.addSubview(instructionsView)
        instructionsView.spacing = theme.instructionsSpacing
        instructionsView.snp.makeConstraints {
            $0.top == headerView.snp.bottom + theme.spacingBetweenInstructionsAndHeader
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addFirstInstruction()
        addSecondInstruction()
        addThirdInstruction()
    }

    private func addFirstInstruction() {
        addInstruction(
            AlgorandSecureBackupFirstInstructionItemViewModel()
        )
    }

    private func addSecondInstruction() {
        let instruction = addInstruction(
            AlgorandSecureBackupSecondInstructionItemViewModel()
        )
        instruction.startObserving(event: .performHyperlinkAction) {
            [unowned self] in
            self.open(AlgorandWeb.algorandSecureBackup.link)
        }
    }

    private func addThirdInstruction() {
        addInstruction(
            AlgorandSecureBackupThirdInstructionItemViewModel()
        )
    }

    @discardableResult
    private func addInstruction(
        _ viewModel: AlgorandSecureBackupInstructionItemViewModel
    ) -> AlgorandSecureBackupInstructionItemView {
        let view = AlgorandSecureBackupInstructionItemView()
        view.customize(theme.instruction)
        view.bindData(viewModel)

        instructionsView.addArrangedSubview(view)
        return view
    }

    private func addStartAction() {
        startActionView.customizeAppearance(theme.startAction)
        startActionView.contentEdgeInsets = UIEdgeInsets(theme.startActionContentEdgeInsets)

        footerView.addSubview(startActionView)
        startActionView.snp.makeConstraints {
            $0.top == theme.startActionEdgeInsets.top
            $0.leading == theme.startActionEdgeInsets.leading
            $0.trailing == theme.startActionEdgeInsets.trailing
            $0.bottom == theme.startActionEdgeInsets.bottom
        }

        startActionView.addTouch(
            target: self,
            action: #selector(performStartAction)
        )

        bindStartAction()
    }
}

extension AlgorandSecureBackupInstructionScreen {
    private func bindHeader() {
        headerView.attributedText =
            "algorand-secure-backup-instruction-header-title"
                .localized
                .bodyRegular()
    }

    private func bindStartAction() {
        startActionView.editTitle = .string("title-start".localized)
    }
}

extension AlgorandSecureBackupInstructionScreen {
    @objc
    private func performStartAction() {
        eventHandler?(.performStart)
    }
}

extension AlgorandSecureBackupInstructionScreen {
    enum Event {
        case performStart
    }
}
