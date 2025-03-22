// Copyright 2024 Pera Wallet, LDA

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
//   AddressNameSetupViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonForm

final class AddressNameSetupViewController:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource {
    private lazy var theme = AddressNameSetupViewControllerTheme()

    private lazy var titleView = UILabel()
    private lazy var descriptionView = UILabel()
    private lazy var walletNameView = UIView()
    private lazy var nameInputView = FloatingTextInputFieldView()
    private lazy var actionView = MacaroonUIKit.Button()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private let flow: AccountSetupFlow
    private let mode: AccountSetupMode
    private let nameServiceName: String?
    private let account: AccountInformation

    init(
        flow: AccountSetupFlow,
        mode: AccountSetupMode,
        nameServiceName: String?,
        account: AccountInformation,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        self.mode = mode
        self.nameServiceName = nameServiceName
        self.account = account
        
        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameInputView.beginEditing()
    }

    override func prepareLayout() {
        super.prepareLayout()

        scrollView.keyboardDismissMode = .onDrag

        addUI()
    }

    override func configureAppearance() {
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        let baseGradientColor = Colors.Defaults.background.uiColor
        backgroundGradient.colors = [
            baseGradientColor.withAlphaComponent(0),
            baseGradientColor
        ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension AddressNameSetupViewController {
    private func addUI() {
        addBackground()
        addTitle()
        addDescription()
        addWalletNameView()
        addNameInput()
        addAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }
    
    private func addWalletNameView() {
        walletNameView.translatesAutoresizingMaskIntoConstraints = false
        walletNameView.backgroundColor = Colors.Button.Float.focusBackground.uiColor
        walletNameView.roundTheCorners(.allCorners, radius: theme.walletNameViewCornerRadius)
        walletNameView.setContentHuggingPriority(.required, for: .vertical)
        
        let walletNameIcon = UIImageView()
        walletNameIcon.customizeAppearance(theme.walletIcon)
        walletNameIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let walletNameLabel = UILabel()
        walletNameLabel.customizeAppearance(theme.walletName)
        walletNameLabel.text = session?.authenticatedUser?.walletName(for: account.hdWalletAddressDetail?.walletId ?? "")
        walletNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        walletNameView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(walletNameView)
            $0.centerY.equalTo(walletNameView)
        }

        containerView.addSubview(walletNameIcon)
        containerView.addSubview(walletNameLabel)
        
        walletNameIcon.snp.makeConstraints {
            $0.width.equalTo(theme.walletIconHeight)
            $0.height.equalTo(theme.walletIconHeight)
            $0.leading.equalTo(containerView)
            $0.centerY.equalTo(containerView)
        }
        walletNameLabel.snp.makeConstraints {
            $0.leading.equalTo(walletNameIcon.snp.trailing).offset(theme.walletNameOffset)
            $0.centerY.equalTo(containerView)
            $0.trailing.equalTo(containerView)
        }

        contentView.addSubview(walletNameView)
        walletNameView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.spacingBetweenDescriptionAndWalletName
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.height.equalTo(theme.walletNameViewMinHeight)
        }
    }

    private func addNameInput() {
        nameInputView.customize(theme.nameInput)

        contentView.addSubview(nameInputView)
        nameInputView.snp.makeConstraints {
            $0.top == walletNameView.snp.bottom + theme.spacingBetweenWalletNameAndNameInput
            $0.leading == theme.contentEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.greaterThanHeight(theme.nameInputMinHeight)
        }

        nameInputView.delegate = self

        bindNameInput()
    }

    private func addAction() {
        actionView.customizeAppearance(theme.action)

        footerView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        actionView.snp.makeConstraints {
            $0.top == theme.actionContentEdgeInsets.top
            $0.leading == theme.actionContentEdgeInsets.leading
            $0.trailing == theme.actionContentEdgeInsets.trailing
            $0.bottom == theme.actionContentEdgeInsets.bottom
        }

        actionView.addTouch(
            target: self,
            action: #selector(setupAddressName)
        )
    }
}

extension AddressNameSetupViewController: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        setupAddressName()
        return true
    }
}

extension AddressNameSetupViewController {
    private func bindNameInput() {
        switch mode {
        case .addBip39Wallet:
            nameInputView.text = nameServiceName.unwrap(or: account.address.shortAddressDisplay)
        case .addBip39Address(newAddress: let newHDWalletAddress):
            guard let newHDWalletAddress = newHDWalletAddress else {
                assertionFailure("Address should exist")
                return
            }
            nameInputView.text = nameServiceName.unwrap(or: newHDWalletAddress.address.shortAddressDisplay)
        default:
            fatalError("Shouldn't enter here")
        }
        
    }
}

extension AddressNameSetupViewController {
    @objc
    private func setupAddressName() {
        nameInputView.endEditing()

        analytics.track(.onboardWatchAccount(type: .create))

        switch mode {
        case .addBip39Wallet:
            
            if
                let nameInput = nameInputView.text,
                !nameInput.isEmpty,
                nameInput != nameServiceName.unwrap(or: account.address.shortAddressDisplay)
            {
                account.updateName(nameInput)
                session?.authenticatedUser?.updateAccount(account)
            }
        case .addBip39Address(newAddress: let newHDWalletAddress):
            guard let newHDWalletAddress = newHDWalletAddress else {
                assertionFailure("Address should exist")
                return
            }
            
            do {
                try hdWalletStorage.save(address: newHDWalletAddress)
            } catch {
                fatalError("Error saving hdWallet: \(error)")
            }
            
            let addressName: String
            if
                let nameInput = nameInputView.text,
                !nameInput.isEmpty
            {
                addressName = nameInput
            } else {
                addressName = nameServiceName.unwrap(or: newHDWalletAddress.address.shortAddressDisplay)
            }
            
            account.updateName(addressName)
            session?.authenticatedUser?.updateAccount(account)
            
        default:
            fatalError("Shouldn't enter here")
        }
        
        openAddressCreatedScreen()
    }

    private func openAddressCreatedScreen() {
        open(
            .tutorial(
                flow: .addNewAccount(mode: mode),
                tutorial: .accountVerified(
                    flow: .addNewAccount(mode: mode),
                    address: "accountAddress"
                )
            ),
            by: .push
        )
    }
}

extension AddressNameSetupViewController {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return nameInputView.frame
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        if let keyboard = keyboardController.keyboard {
            footerBackgroundView.snp.updateConstraints {
                $0.bottom == keyboard.height
            }

            let animator = UIViewPropertyAnimator(
                duration: keyboard.animationDuration,
                curve: keyboard.animationCurve
            ) {
                [unowned self] in
                view.layoutIfNeeded()
            }
            animator.startAnimation()
        }

        return spacingBetweenContentAndKeyboard()
    }

    private func spacingBetweenContentAndKeyboard() -> LayoutMetric {
        return footerView.frame.height
    }

    func bottomInsetWhenKeyboardDidHide(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        /// <note>
        /// It doesn't scroll to the bottom during the transition to another screen. When the
        /// screen is back, it will show the keyboard again anyway.
        if isViewDisappearing {
            return scrollView.contentInset.bottom
        }

        footerBackgroundView.snp.updateConstraints {
            $0.bottom == 0
        }

        let animator = UIViewPropertyAnimator(
            duration:  0.25,
            curve: .easeOut
        ) {
            [unowned self] in
            view.layoutIfNeeded()
        }
        animator.startAnimation()

        return .zero
    }
}
