//
//  AlertViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlertViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) var alertView: AlertView
    private let mode: Mode
    private let alertConfigurator: AlertViewConfigurator
    
    private let viewModel = AlertViewModel()
    
    init(mode: Mode, alertConfigurator: AlertViewConfigurator, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.alertConfigurator = alertConfigurator
        
        switch mode {
        case .default:
            alertView = DefaultAlertView()
        case .destructive:
            alertView = DestructiveAlertView()
        case .qr:
            alertView = QRAlertView()
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        viewModel.configure(alertView, with: alertConfigurator)
    }
    
    override func setListeners() {
        switch mode {
        case .default:
            setDefaultAlertViewAction()
        case .destructive:
            setDestructiveAlertViewAction()
        case .qr:
            setQRAlertViewAction()
        }
    }
    
    override func prepareLayout() {
        setupAlertViewLayout()
    }
}

extension AlertViewController {
    private func setupAlertViewLayout() {
        view.addSubview(alertView)
        
        alertView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.center.equalToSuperview()
        }
    }
}

extension AlertViewController {
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
    
    private func setQRAlertViewAction() {
        guard let qrAlertView = alertView as? QRAlertView else {
            return
        }
        
        qrAlertView.delegate = self
    }
}

extension AlertViewController {
    private func executeHandler() {
        if let handler = alertConfigurator.actionHandler {
            dismiss(animated: true) {
                handler()
            }
            return
        }
        
        dismissScreen()
    }
}

extension AlertViewController: DefaultAlertViewDelegate {
    func defaultAlertViewDidTapDoneButton(_ alertView: DefaultAlertView) {
        executeHandler()
    }
}

extension AlertViewController: DestructiveAlertViewDelegate {
    func destructiveAlertViewDidTapCancelButton(_ alertView: DestructiveAlertView) {
        dismissScreen()
    }
    
    func destructiveAlertViewDidTapActionButton(_ alertView: DestructiveAlertView) {
        executeHandler()
    }
}

extension AlertViewController: QRAlertViewDelegate {
    func qRAlertViewDidTapCancelButton(_ alertView: QRAlertView) {
        dismissScreen()
    }
    
    func qrAlertViewDidTapActionButton(_ alertView: QRAlertView) {
        executeHandler()
    }
}

extension AlertViewController {
    enum Mode {
        case `default`
        case destructive
        case qr
    }
}

extension AlertViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

extension AlertViewController {
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
}
