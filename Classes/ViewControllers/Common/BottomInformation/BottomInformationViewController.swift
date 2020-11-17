//
//  BottomInformationViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BottomInformationViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private(set) var bottomInformationView: BottomInformationView
    private let mode: Mode
    private let bottomInformationBundle: BottomInformationBundle
    
    private let viewModel = BottomInformationViewModel()
    
    init(mode: Mode, bottomInformationBundle: BottomInformationBundle, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.bottomInformationBundle = bottomInformationBundle
        
        switch mode {
        case .confirmation:
            bottomInformationView = ConfirmationBottomInformationView()
        case .action:
            bottomInformationView = ActionBottomInformationView()
        case .qr:
            bottomInformationView = QRBottomInformationView()
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        viewModel.configure(bottomInformationView, with: bottomInformationBundle)
    }
    
    override func setListeners() {
        switch mode {
        case .confirmation:
            setConfirmationBottomInformationViewAction()
        case .action:
            setActionBottomInformationViewAction()
        case .qr:
            setQRBottomInformationViewAction()
        }
    }
    
    override func prepareLayout() {
        setupBottomInformationViewLayout()
    }
}

extension BottomInformationViewController {
    private func setupBottomInformationViewLayout() {
        view.addSubview(bottomInformationView)
        
        bottomInformationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension BottomInformationViewController {
    private func setConfirmationBottomInformationViewAction() {
        guard let confirmationBottomInformationView = bottomInformationView as? ConfirmationBottomInformationView else {
            return
        }
        
        confirmationBottomInformationView.delegate = self
    }
    
    private func setActionBottomInformationViewAction() {
        guard let actionBottomInformationView = bottomInformationView as? ActionBottomInformationView else {
            return
        }
        
        actionBottomInformationView.delegate = self
    }
    
    private func setQRBottomInformationViewAction() {
        guard let qrBottomInformationView = bottomInformationView as? QRBottomInformationView else {
            return
        }
        
        qrBottomInformationView.delegate = self
    }
}

extension BottomInformationViewController {
    private func executeHandler() {
        if let handler = bottomInformationBundle.actionHandler {
            dismiss(animated: true) {
                handler()
            }
            return
        }
        
        dismissScreen()
    }
}

extension BottomInformationViewController: ConfirmationBottomInformationViewDelegate {
    func confirmationBottomInformationViewDidTapActionButton(_ confirmationBottomInformationView: ConfirmationBottomInformationView) {
        executeHandler()
    }
}

extension BottomInformationViewController: ActionBottomInformationViewDelegate {
    func actionBottomInformationViewDidTapCancelButton(_ actionBottomInformationView: ActionBottomInformationView) {
        dismissScreen()
    }
    
    func actionBottomInformationViewDidTapActionButton(_ actionBottomInformationView: ActionBottomInformationView) {
        executeHandler()
    }
}

extension BottomInformationViewController: QRBottomInformationViewDelegate {
    func qrBottomInformationViewDidTapCancelButton(_ qrBottomInformationView: QRBottomInformationView) {
        dismissScreen()
    }
    
    func qrBottomInformationViewDidTapActionButton(_ qrBottomInformationView: QRBottomInformationView) {
        executeHandler()
    }
}

extension BottomInformationViewController {
    enum Mode {
        case confirmation
        case action
        case qr
    }
}
