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
//  EditAccountViewController.swift

import UIKit
import SnapKit

final class EditAccountViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var editAccountView = EditAccountView()
    
    private lazy var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?

    private lazy var modalSize: ModalSize = {
        let keyboardHeight = keyboard.height ?? 0
        let size = CGSize(
            width: view.bounds.width,
            height: keyboardHeight + 244
        )
        return .custom(size)
    }()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "options-edit-account-name".localized
    }
    
    override func setListeners() {
        editAccountView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func prepareLayout() {
        editAccountView.customize(theme.editAccountViewTheme)
        view.addSubview(editAccountView)
        editAccountView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = $0.bottom.equalToSuperview().inset(0).constraint
        }
    }

    override func bindData() {
        editAccountView.bindData(account.name)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editAccountView.beginEditing()
    }
}

extension EditAccountViewController {
    private func didTapDoneButton() {
        guard let name = editAccountView.accountNameInputView.text else {
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "account-name-setup-empty-error-message".localized
            )
            return
        }

        account.name = name
        session?.updateName(name, for: account.address)
        dismissScreen()
    }
}

extension EditAccountViewController {
    @objc
    private func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? 0
        
        keyboard.height = kbHeight
        
        let inset = kbHeight - self.view.safeAreaInsets.bottom
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        self.contentViewBottomConstraint?.update(inset: inset)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [curveAnimationOption],
            animations: {
                self.modalPresenter?.changeModalSize(to: self.modalSize, animated: false)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension EditAccountViewController: EditAccountViewDelegate {
    func editAccountViewDidTapDoneButton(_ editAccountView: EditAccountView) {
        didTapDoneButton()
    }

    func editAccountViewDidChangeValue(_ editAccountView: EditAccountView) {}
}
