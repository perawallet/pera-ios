//
//  AccountsHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountsHeaderViewDelegate: class {
    func accountsHeaderViewDidTapSendButton(_ accountsHeaderView: AccountsHeaderView)
    func accountsHeaderViewDidTapReceiveButton(_ accountsHeaderView: AccountsHeaderView)
    func accountsHeaderView(_ accountsHeaderView: AccountsHeaderView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer)
}

class AccountsHeaderView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let containerViewInset: CGFloat = 10.0
        let availableTitleInset: CGFloat = 15.0
        let dollarValueSize = CGSize(width: 44.0, height: 44.0)
        let dollarValueInset: CGFloat = 5.0
        let horizontalInset: CGFloat = 15.0
        let verticalInset: CGFloat = 20.0
        let buttonHeight: CGFloat = 46.0
        let historyLabelBottomInset: CGFloat = 10.0
        let amountLabelTopInset: CGFloat = -10.0
        let amountLabelLeadingInset: CGFloat = 6.0
        let buttonTopInset: CGFloat = 35.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    private lazy var dollarValueGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToDollarValueLabelTapped))
        recognizer.minimumPressDuration = 0.0
        return recognizer
    }()
    
    // MARK: Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var algosAvailableLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withText("accounts-algos-available-title".localized)
    }()
    
    private(set) lazy var algosImageView = UIImageView(image: img("algo-icon-accounts"))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 38.0)))
            .withText("0.000000")
    }()
    
    private(set) lazy var dollarImageView = UIImageView(image: img("icon-dollar-black"))
    
    private(set) lazy var dollarAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 38.0)))
    }()
    
    private(set) lazy var dollarValueLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
            .withText("$")
            .withTextColor(.black)
        
        label.isUserInteractionEnabled = true
        label.clipsToBounds = true
        label.backgroundColor = .white
        label.layer.borderWidth = 1.0
        label.layer.borderColor = Colors.borderColor.cgColor
        label.layer.cornerRadius = 20.0
        return label
    }()
    
    private lazy var sendButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 10.0, y: 0.0), title: CGPoint(x: -12.0, y: 0.0))
        
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-arrow-up"), for: .normal)
        button.setTitle("title-send".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.font(.avenir, withWeight: .demiBold(size: 12.0))
        button.backgroundColor = SharedColors.orange
        button.layer.cornerRadius = 23.0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var requestButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 10.0, y: 0.0), title: CGPoint(x: -12.0, y: 0.0))
        
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-arrow-down"), for: .normal)
        button.setTitle("title-request".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.font(.avenir, withWeight: .demiBold(size: 12.0))
        button.backgroundColor = SharedColors.turquois
        button.layer.cornerRadius = 23.0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var historyLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 12.0)))
            .withText("accounts-transaction-history-title".localized)
    }()
    
    weak var delegate: AccountsHeaderViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        dollarAmountLabel.isHidden = true
        dollarImageView.isHidden = true
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(notifyDelegateToReceiveButtonTapped), for: .touchUpInside)
        dollarValueLabel.addGestureRecognizer(dollarValueGestureRecognizer)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupDollarValueLabelLayout()
        setupAlgosAvailableLabelLayout()
        setupAlgosImageViewLayout()
        setupAmountLabelLayout()
        setupDollarImageViewLayout()
        setupDollarAmountLabelLayout()
        setupSendButtonLayout()
        setupRequestButtonLayout()
        setupHistoryLabelLayout()
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.containerViewInset)
        }
    }
    
    private func setupDollarValueLabelLayout() {
        addSubview(dollarValueLabel)
        
        dollarValueLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).inset(-layout.current.dollarValueInset)
            make.trailing.equalTo(containerView).offset(layout.current.dollarValueInset)
            make.size.equalTo(layout.current.dollarValueSize)
        }
    }
    
    private func setupAlgosAvailableLabelLayout() {
        containerView.addSubview(algosAvailableLabel)
        
        algosAvailableLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.lessThanOrEqualToSuperview().inset(layout.current.availableTitleInset)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        containerView.addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.top.equalTo(algosAvailableLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAmountLabelLayout() {
        containerView.addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(algosImageView.snp.top).inset(layout.current.amountLabelTopInset)
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.amountLabelLeadingInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDollarImageViewLayout() {
        containerView.addSubview(dollarImageView)
        
        dollarImageView.snp.makeConstraints { make in
            make.top.equalTo(algosAvailableLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDollarAmountLabelLayout() {
        containerView.addSubview(dollarAmountLabel)
        
        dollarAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(algosImageView.snp.top).inset(layout.current.amountLabelTopInset)
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.amountLabelLeadingInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSendButtonLayout() {
        containerView.addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(algosImageView.snp.bottom).offset(layout.current.buttonTopInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.bottom.equalToSuperview().inset(layout.current.availableTitleInset)
        }
    }
    
    private func setupRequestButtonLayout() {
        containerView.addSubview(requestButton)
        
        requestButton.snp.makeConstraints { make in
            make.leading.equalTo(sendButton.snp.trailing).offset(layout.current.horizontalInset)
            make.width.height.equalTo(sendButton)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalTo(sendButton)
        }
    }
    
    private func setupHistoryLabelLayout() {
        addSubview(historyLabel)

        historyLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.historyLabelBottomInset)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.accountsHeaderViewDidTapSendButton(self)
    }
    
    @objc
    private func notifyDelegateToReceiveButtonTapped() {
        delegate?.accountsHeaderViewDidTapReceiveButton(self)
    }
    
    @objc
    private func notifyDelegateToDollarValueLabelTapped(dollarValueGestureRecognizer: UILongPressGestureRecognizer) {
        delegate?.accountsHeaderView(self, didTrigger: dollarValueGestureRecognizer)
    }
}
