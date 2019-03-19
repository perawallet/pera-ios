//
//  PassPhraseBackUpView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol PassPhraseBackUpViewDelegate: class {
    
    func passPhraseBackUpViewDidTapVerifyButton(_ passPhraseBackUpView: PassPhraseBackUpView)
}

class PassPhraseBackUpView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 94.0
        let createButtonTopInset: CGFloat = 42.0
        let bottomInset: CGFloat = 83.0
        let buttonMinimumTopInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(rgb(0.0, 0.46, 1.0))
            .withFont(UIFont.systemFont(ofSize: 22.0, weight: .bold))
            .withText("welcome-title".localized)
    }()
    
    private lazy var passPhraseContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var passPhreaseLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(rgb(0.04, 0.05, 0.07))
            .withFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
    }()
    
    private lazy var warningContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var warningImageView = UIImageView(image: img(""))
    
    private lazy var warningLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(rgb(0.04, 0.05, 0.07))
            .withFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
            .withText("welcome-subtitle".localized)
    }()
    
    private lazy var verifyButton: MainButton = {
        let button = MainButton(title: "VERIFY RECOVERY PHRASE".localized)
        return button
    }()
    
    weak var delegate: PassPhraseBackUpViewDelegate?
    
    // MARK: Configuration
    
    override func configureAppearance() {
        backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    override func setListeners() {
        
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupPassPhraseContainerViewLayout()
        setupPassPhraseLabelLayout()
        setupWarningContainerViewLayout()
        setupWarningImageViewLayout()
        setupWarningLabelLayout()
        setupVerifyButtonLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupPassPhraseContainerViewLayout() {
        addSubview(passPhraseContainerView)
        
        passPhraseContainerView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupPassPhraseLabelLayout() {
        passPhraseContainerView.addSubview(passPhreaseLabel)
        
        passPhreaseLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupWarningContainerViewLayout() {
        addSubview(warningContainerView)
        
        warningContainerView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupWarningImageViewLayout() {
        warningContainerView.addSubview(warningImageView)
        
        warningImageView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupWarningLabelLayout() {
        warningContainerView.addSubview(warningLabel)
        
        warningLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupVerifyButtonLayout() {
        addSubview(verifyButton)
        
        verifyButton.snp.makeConstraints { make in
            
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToVerifyButtonTapped() {
        delegate?.passPhraseBackUpViewDidTapVerifyButton(self)
    }
}
