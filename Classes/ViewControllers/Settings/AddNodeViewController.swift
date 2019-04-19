//
//  AddNodeViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

class AddNodeViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var addNodeView = AddNodeView()
    
    private var contentViewBottomConstraint: Constraint?
    
    private var keyboard = Keyboard()
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        
        super.init(configuration: configuration)
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillHide:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        switch mode {
        case .new:
            title = "add-node-title".localized
            return
        case let .edit(node):
            title = "edit-node-title".localized
            
            addNodeView.nameInputView.inputTextField.text = node.name
            addNodeView.addressInputView.inputTextField.text = node.address
            addNodeView.tokenInputView.inputTextField.text = node.token
        }
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        switch mode {
        case .new:
            return
        case let .edit(node):
            let barButtonItem = ALGBarButtonItem(kind: .removeNode) {
                let alertController = UIAlertController(title: "node-settings-warning-title".localized,
                                                        message: "node-settings-warning-message".localized,
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(
                    title: "node-settings-action-delete-title".localized,
                    style: .destructive) { _ in
                        node.remove(entity: Node.entityName)
                        self.popScreen()
                        return
                }
                alertController.addAction(deleteAction)
                
                self.present(alertController, animated: true)
            }
            
            rightBarButtonItems = [barButtonItem]
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        scrollView.touchDetectingDelegate = self
        addNodeView.testButton.addTarget(self, action: #selector(tap(test:)), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(addNodeView)
        
        addNodeView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
    
    // MARK: Keyboard
    
    @objc
    fileprivate func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? view.safeAreaBottom
        
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        if addNodeView.tokenInputView.frame.maxY > UIScreen.main.bounds.height - kbHeight - 76.0 {
            scrollView.contentInset.bottom = kbHeight
        } else {
            contentViewBottomConstraint?.update(inset: kbHeight)
        }
        
        contentViewBottomConstraint?.update(inset: kbHeight)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc
    fileprivate func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        scrollView.contentInset.bottom = 0.0
        
        contentViewBottomConstraint?.update(inset: view.safeAreaBottom)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc
    fileprivate func tap(test button: MainButton) {
        view.endEditing(true)
        
        guard let name = addNodeView.nameInputView.inputTextField.text, !name.isEmpty,
            let address = addNodeView.addressInputView.inputTextField.text, !address.isEmpty,
            let token = addNodeView.tokenInputView.inputTextField.text, !token.isEmpty else {
                displaySimpleAlertWith(title: "title-error".localized,
                                       message: "node-settings-text-validation-empty-error".localized)
                return
        }
        
        let testDraft = NodeTestDraft(address: address, token: token)
        
        let predicate = NSPredicate(format: "address = %@", address)
        
        switch self.mode {
        case .new:
            if Node.hasResult(entity: Node.entityName, with: predicate) {
                displaySimpleAlertWith(title: "title-error".localized, message: "node-settings-has-same-result".localized)
                return
            }
        default:
            break
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.checkHealth(with: testDraft) { isValidated in
            SVProgressHUD.dismiss()
            
            if isValidated {
                switch self.mode {
                case .new:
                    self.createNode(with: [Node.DBKeys.name.rawValue: name,
                                           Node.DBKeys.address.rawValue: address,
                                           Node.DBKeys.token.rawValue: token,
                                           Node.DBKeys.creationDate.rawValue: Date()])
                case let .edit(node):
                    self.edit(node, with: [Node.DBKeys.name.rawValue: name,
                                           Node.DBKeys.address.rawValue: address,
                                           Node.DBKeys.token.rawValue: token])
                }
                
                self.popScreen()
            } else {
                self.displayAlert(message: "node-settings-text-validation-health-error".localized,
                                  mode: .testFail)
            }
        }
    }
    
    private func createNode(with values: [String: Any]) {
        Node.create(
            entity: Node.entityName,
            with: values
        ) { response in
            switch response {
            case .error:
                self.displayAlert(message: "node-settings-database-error-description".localized,
                                  mode: .dbFail)
            case let .result(object):
                guard object is Node else {
                    self.displayAlert(message: "node-settings-database-error-description".localized,
                                      mode: .dbFail)
                    return
                }
                
                self.displayAlert(message: "node-settings-success-add-description".localized,
                                  mode: .success)
                
            case let .results(objects):
                guard objects.first is Node else {
                    self.displayAlert(message: "node-settings-database-error-description".localized,
                                      mode: .dbFail)
                    return
                }
                
                self.displayAlert(message: "node-settings-success-add-description".localized,
                                  mode: .success)
            }
        }
    }
    
    private func edit(_ node: Node, with values: [String: Any]) {
        node.update(entity: Node.entityName, with: values) { result in
            switch result {
            case let .result(object):
                guard object is Node else {
                    self.displayAlert(message: "node-settings-database-error-description".localized,
                                      mode: .dbFail)
                    return
                }
                
                self.displayAlert(message: "node-settings-success-edit-description".localized,
                                  mode: .success)
                
            case .error:
                self.displayAlert(message: "node-settings-database-error-description".localized,
                                  mode: .dbFail)
            default:
                break
            }
        }
    }
    
    private func displayAlert(message: String, mode: AlertMode) {
        let alertTitle: String
        let image: UIImage?
        
        switch mode {
        case .dbFail:
            alertTitle = "node-settings-db-error-title".localized
            image = img("icon-red-server")
        case .testFail:
            alertTitle = "node-settings-test-error-title".localized
            image = img("icon-red-server")
        case .success:
            switch self.mode {
            case .edit:
                alertTitle = "node-settings-success-edit-title".localized
            case .new:
                alertTitle = "node-settings-success-add-title".localized
            }
            
            image = img("icon-server")
        }
        
        let configurator = AlertViewConfigurator(
            title: alertTitle,
            image: image,
            explanation: message,
            actionTitle: "title-close".localized) {
                if mode == .success {
                    self.popScreen()
                }
        }
        
        let viewController = AlertViewController(mode: mode == .success ? .default : .destructive,
                                                 alertConfigurator: configurator,
                                                 configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}

// MARK: Mode

extension AddNodeViewController {
    
    enum Mode {
        case new
        case edit(node: Node)
    }
    
    enum AlertMode {
        case dbFail
        case testFail
        case success
    }
}

// MARK: TouchDetectingScrollViewDelegate

extension AddNodeViewController: TouchDetectingScrollViewDelegate {
    
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if addNodeView.testButton.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}
