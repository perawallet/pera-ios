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
    private let bottomInformationViewConfigurator: BottomInformationViewConfigurator
    
    private let viewModel = BottomInformationViewModel()
    
    init(mode: Mode, bottomInformationViewConfigurator: BottomInformationViewConfigurator, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.bottomInformationViewConfigurator = bottomInformationViewConfigurator
        
        switch mode {
        case .default:
            bottomInformationView = DefaultBottomInformationView()
        case .action:
            bottomInformationView = ActionBottomInformationView()
        case .qr:
            bottomInformationView = QRBottomInformationView()
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
        viewModel.configure(bottomInformationView, with: bottomInformationViewConfigurator)
    }
    
    override func setListeners() {
        switch mode {
        case .default:
            setDefaultBottomInformationViewAction()
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
    private func setDefaultBottomInformationViewAction() {
        guard let defaultBottomInformationView = bottomInformationView as? DefaultBottomInformationView else {
            return
        }
        
        defaultBottomInformationView.delegate = self
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
        if let handler = bottomInformationViewConfigurator.actionHandler {
            dismiss(animated: true) {
                handler()
            }
            return
        }
        
        dismissScreen()
    }
}

extension BottomInformationViewController: DefaultBottomInformationViewDelegate {
    func defaultBottomInformationViewDidTapActionButton(_ defaultBottomInformationView: DefaultBottomInformationView) {
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
        case `default`
        case action
        case qr
    }
}
