//
//  ReceiveAlgosView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ReceiveAlgosViewDelegate: class {
    
    func receiveAlgosViewDidTapAccountSelectionView(_ receiveAlgosView: ReceiveAlgosView)
    func receiveAlgosViewDidTapPreviewButton(_ receiveAlgosView: ReceiveAlgosView)
}

class ReceiveAlgosView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 25.0
        let bottomInset: CGFloat = 18.0
        let buttonMinimumInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ReceiveAlgosViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var algosInputView: AlgosInputView = {
        let view = AlgosInputView()
        return view
    }()
    
    private(set) lazy var accountSelectionView: SingleLineInputField = {
        let selectAccountView = SingleLineInputField(displaysRightInputAccessoryButton: true)
        selectAccountView.explanationLabel.text = "send-algos-from".localized
        selectAccountView.inputTextField.text = "send-algos-select".localized
        selectAccountView.rightInputAccessoryButton.setImage(img("icon-arrow"), for: .normal)
        selectAccountView.inputTextField.isEnabled = false
        selectAccountView.inputTextField.textColor = SharedColors.black
        selectAccountView.inputTextField.tintColor = SharedColors.black
        return selectAccountView
    }()
    
    private(set) lazy var previewButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 12.0)))
            .withBackgroundImage(img("bg-dark-gray-button-big"))
            .withTitle("title-preview".localized)
            .withTitleColor(SharedColors.black)
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notifyDelegateToAccountSelectionViewTapped))
        
        accountSelectionView.isUserInteractionEnabled = true
        accountSelectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func linkInteractors() {
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAlgosInputViewLayout()
        setupAccountSelectionViewLayout()
        setupPreviewButtonLayout()
    }
    
    private func setupAlgosInputViewLayout() {
        addSubview(algosInputView)
        
        algosInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalTo(algosInputView.snp.bottom).offset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
        
        accountSelectionView.rightInputAccessoryButton.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(56.0)
            make.top.greaterThanOrEqualTo(accountSelectionView.snp.bottom).offset(layout.current.buttonMinimumInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.receiveAlgosViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.receiveAlgosViewDidTapAccountSelectionView(self)
    }
}
