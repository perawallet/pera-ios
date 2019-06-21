//
//  DepositView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol DepositViewDelegate: class {
    
    func depositViewDidTapDepositButton(_ depositView: DepositView)
    func depositViewDidTapCancelButton(_ depositView: DepositView)
    func depositView(_ depositView: DepositView, didSelect depositType: DepositType)
}

class DepositView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let balanceHeaderHeight: CGFloat = 100.0
        let defaultInset: CGFloat = 27.0
        let horizontalInset: CGFloat = 20.0
        let labelBottomInset: CGFloat = 8.0
        let buttonSpacing: CGFloat = 15.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: DepositViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var balanceHeaderView: BalanceHeaderView = {
        let view = BalanceHeaderView()
        return view
    }()
    
    private(set) lazy var depositAmountView: DepositAmountView = {
        let view = DepositAmountView()
        return view
    }()
    
    private(set) lazy var depositFundSelectionView: DepositFundSelectionView = {
        let view = DepositFundSelectionView()
        return view
    }()
    
    private(set) lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.darkGray)
            .withTitle("title-cancel".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("button-bg-gray-small"))
    }()
    
    private(set) lazy var depositButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.blue)
            .withTitle("balance-button-title-deposit".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("button-bg-navy-small"))
    }()
    
    private lazy var bottomExplanationLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("deposit-bottom-title".localized)
        label.isHidden = true
        return label
    }()
    
    // MARK: Setup
    
    override func linkInteractors() {
        depositFundSelectionView.delegate = self
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelButtonTapped), for: .touchUpInside)
        depositButton.addTarget(self, action: #selector(notifyDelegateToDepositButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBalanceHeaderViewLayout()
        setupDepositAmountViewLayout()
        setupDepositFundSelectionViewLayout()
        setupCancelButtonLayout()
        setupDepositButtonLayout()
        setupBottomExplanationLabelLayout()
    }
    
    private func setupBalanceHeaderViewLayout() {
        addSubview(balanceHeaderView)
        
        balanceHeaderView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.balanceHeaderHeight)
        }
    }
    
    private func setupDepositAmountViewLayout() {
        addSubview(depositAmountView)
        
        depositAmountView.snp.makeConstraints { make in
            make.top.equalTo(balanceHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupDepositFundSelectionViewLayout() {
        addSubview(depositFundSelectionView)
        
        depositFundSelectionView.snp.makeConstraints { make in
            make.top.equalTo(depositAmountView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(depositFundSelectionView.snp.bottom).offset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDepositButtonLayout() {
        addSubview(depositButton)
        
        depositButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton)
            make.width.height.equalTo(cancelButton)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.equalTo(cancelButton.snp.trailing).offset(layout.current.buttonSpacing)
        }
    }
    
    private func setupBottomExplanationLabelLayout() {
        addSubview(bottomExplanationLabel)
        
        bottomExplanationLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(layout.current.defaultInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.labelBottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToDepositButtonTapped() {
        delegate?.depositViewDidTapDepositButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.depositViewDidTapCancelButton(self)
    }
}

// MARK: DepositFundSelectionViewDelegate

extension DepositView: DepositFundSelectionViewDelegate {
    
    func depositFundSelectionView(_ depositFundSelectionView: DepositFundSelectionView, didSelect depositType: DepositType) {
        delegate?.depositView(self, didSelect: depositType)
    }
}
