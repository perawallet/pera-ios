//
//  ReceiveAlgosView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol RequestAlgosViewDelegate: class {
    
    func requestAlgosViewDidTapAccountSelectionView(_ requestAlgosView: RequestAlgosView)
    func requestAlgosViewDidTapPreviewButton(_ requestAlgosView: RequestAlgosView)
}

class RequestAlgosView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 25.0
        let bottomInset: CGFloat = 18.0
        let buttonInset: CGFloat = 15.0
        let buttonMinimumInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RequestAlgosViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var algosInputView: AlgosInputView = {
        let view = AlgosInputView()
        return view
    }()
    
    private(set) lazy var accountSelectionView: AccountSelectionView = {
        let accountSelectionView = AccountSelectionView()
        accountSelectionView.explanationLabel.text = "send-algos-to".localized
        return accountSelectionView
    }()
    
    private(set) lazy var previewButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("bg-main-button"))
            .withTitle("title-preview".localized)
            .withTitleColor(SharedColors.purple)
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
            make.top.equalTo(algosInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
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
        delegate?.requestAlgosViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.requestAlgosViewDidTapAccountSelectionView(self)
    }
}
