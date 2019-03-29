//
//  AlertViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

typealias EmptyHandler = () -> Void

class AlertViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private let alertView: AlertView
    private let mode: Mode
    private let alertConfigurator: AlertViewConfigurator
    
    private let viewModel = AlertViewModel()
    
    // MARK: Initialization
    
    init(mode: Mode, alertConfigurator: AlertViewConfigurator, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.alertConfigurator = alertConfigurator
        
        if mode == .default {
            alertView = DefaultAlertView()
        } else {
            alertView = DestructiveAlertView()
        }
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        viewModel.configure(alertView, with: alertConfigurator)
    }
    
    override func setListeners() {
        if mode == .default {
            setDefaultAlertViewAction()
            return
        }
        
        setDestructiveAlertViewAction()
    }
    
    private func setDefaultAlertViewAction() {
        guard let defaultAlertView = alertView as? DefaultAlertView else {
            return
        }
        
        defaultAlertView.delegate = self
    }
    
    private func setDestructiveAlertViewAction() {
        guard let destructiveAlertView = alertView as? DestructiveAlertView else {
            return
        }
        
        destructiveAlertView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(alertView)
        
        alertView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.center.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    private func executeHandler() {
        if let handler = alertConfigurator.actionHandler {
            dismissScreen()
            handler()
            return
        }
        
        dismissScreen()
    }
}

// MARK: DefaultAlertViewDelegate

extension AlertViewController: DefaultAlertViewDelegate {
    
    func defaultAlertViewDidTapDoneButton(_ alertView: DefaultAlertView) {
        executeHandler()
    }
}

// MARK: DestructiveAlertViewDelegate

extension AlertViewController: DestructiveAlertViewDelegate {
    
    func destructiveAlertViewDidTapCancelButton(_ alertView: DestructiveAlertView) {
        dismissScreen()
    }
    
    func destructiveAlertViewDidTapActionButton(_ alertView: DestructiveAlertView) {
        executeHandler()
    }
}

// MARK: AlertViewController.Mode

extension AlertViewController {
    
    enum Mode {
        case `default`
        case destructive
    }
}
