//
//  ChoosePasswordViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ChoosePasswordViewController: BaseViewController {
    
    private lazy var choosePasswordView: ChoosePasswordView = {
        let view = ChoosePasswordView()
        return view
    }()
    
    private let viewModel: ChoosePasswordViewModel
    private let mode: Mode
    
    // MARK: Initialization
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.viewModel = ChoosePasswordViewModel(mode: mode)
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        viewModel.configure(choosePasswordView)
        
        title = "choose-password-title".localized
    }
    
    override func prepareLayout() {
        view.addSubview(choosePasswordView)
        
        choosePasswordView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    override func linkInteractors() {
        choosePasswordView.delegate = self
    }
}

extension ChoosePasswordViewController: ChoosePasswordViewDelegate {
    
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadValue) {
        switch mode {
        case .setup:
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                open(.choosePassword(.verify(password)), by: .push)
            }
        case let .verify(previousPassword):
            viewModel.configureSelection(in: choosePasswordView, for: value) { password in
                if password != previousPassword {
                    displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                    return
                }
                
                open(.localAuthenticationPreference, by: .push)
            }
        }
    }
}

extension ChoosePasswordViewController {
    
    enum Mode {
        case setup
        case verify(String)
    }
}
