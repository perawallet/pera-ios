//
//  USDWireInstructionContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class USDWireInstructionContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewWidth: CGFloat = UIScreen.main.bounds.width / 2
        let horizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let referenceContainerTopInset: CGFloat = 7.0
        let referenceContainerTrailingInset: CGFloat = 25.0
        let referenceContainerSize = CGSize(width: 150.0, height: 60.0)
        let referenceTitleLeadingInset: CGFloat = 11.0
        let referenceTitleTopInset: CGFloat = 8.0
        let referenceValueLabelInset: CGFloat = 2.0
        let bottomLabelVerticalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
        static let referenceBackgroundColor = rgba(0.91, 0.36, 0.16, 0.05)
    }
    
    // MARK: Components
    
    private(set) lazy var sendInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-send-title".localized
        return view
    }()
    
    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var bankInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-bank-title".localized
        return view
    }()
    
    private(set) lazy var creditInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-credit-to-title".localized
        return view
    }()
    
    private lazy var centerSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var routingInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-routing-number-title".localized
        return view
    }()
    
    private(set) lazy var accountInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-account-number-title".localized
        return view
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var swiftInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-swift-title".localized
        return view
    }()
    
    private lazy var referenceContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.referenceBackgroundColor
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.5
        view.layer.borderColor = SharedColors.orange.cgColor
        return view
    }()

    private lazy var referenceTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.orange)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withText("balance-reference-title".localized)
    }()
    
    private(set) lazy var referenceLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 14.0)))
    }()
    
    private(set) lazy var bottomDetailLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.orange)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("balance-reference-number-warning".localized)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupSendInformationViewLayout()
        setupTopSeparatorViewLayout()
        setupBankInformationViewLayout()
        setupCreditInformationViewLayout()
        setupCenterSeparatorViewLayout()
        setupRoutingInformationViewLayout()
        setupAccountInformationViewLayout()
        setupBottomSeparatorViewLayout()
        setupSwiftInformationViewLayout()
        setupReferenceContainerViewLayout()
        setupReferenceTitleLabelLayout()
        setupReferenceLabelLayout()
        setupBottomDetailLabelLayout()
    }
    
    private func setupSendInformationViewLayout() {
        addSubview(sendInformationView)
        
        sendInformationView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }
    
    private func setupTopSeparatorViewLayout() {
        addSubview(topSeparatorView)
        
        topSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(sendInformationView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupBankInformationViewLayout() {
        addSubview(bankInformationView)
        
        bankInformationView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(topSeparatorView.snp.bottom)
            make.width.equalTo(layout.current.informationViewWidth)
        }
    }
    
    private func setupCreditInformationViewLayout() {
        addSubview(creditInformationView)
        
        creditInformationView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(topSeparatorView.snp.bottom)
            make.width.equalTo(layout.current.informationViewWidth)
            make.height.equalTo(bankInformationView)
        }
    }
    
    private func setupCenterSeparatorViewLayout() {
        addSubview(centerSeparatorView)
        
        centerSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(bankInformationView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupRoutingInformationViewLayout() {
        addSubview(routingInformationView)
        
        routingInformationView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(centerSeparatorView.snp.bottom)
            make.width.equalTo(layout.current.informationViewWidth)
        }
    }
    
    private func setupAccountInformationViewLayout() {
        addSubview(accountInformationView)
        
        accountInformationView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(centerSeparatorView.snp.bottom)
            make.width.equalTo(layout.current.informationViewWidth)
            make.height.equalTo(routingInformationView)
        }
    }
    
    private func setupBottomSeparatorViewLayout() {
        addSubview(bottomSeparatorView)
        
        bottomSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(routingInformationView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupSwiftInformationViewLayout() {
        addSubview(swiftInformationView)
        
        swiftInformationView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(bottomSeparatorView.snp.bottom)
            make.width.equalTo(layout.current.informationViewWidth)
        }
    }
    
    private func setupReferenceContainerViewLayout() {
        addSubview(referenceContainerView)
        
        referenceContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.referenceContainerTrailingInset)
            make.top.equalTo(bottomSeparatorView.snp.bottom).offset(layout.current.referenceContainerTopInset)
            make.size.equalTo(layout.current.referenceContainerSize)
        }
    }
    
    
    private func setupReferenceTitleLabelLayout() {
        referenceContainerView.addSubview(referenceTitleLabel)
        
        referenceTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.referenceTitleLeadingInset)
            make.top.equalToSuperview().inset(layout.current.referenceTitleTopInset)
        }
    }
    
    
    private func setupReferenceLabelLayout() {
        referenceContainerView.addSubview(referenceLabel)
        
        referenceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.referenceTitleLeadingInset)
            make.top.equalTo(referenceTitleLabel.snp.bottom).offset(layout.current.referenceValueLabelInset)
            make.trailing.equalToSuperview().inset(layout.current.referenceValueLabelInset)
        }
    }
    
    private func setupBottomDetailLabelLayout() {
        addSubview(bottomDetailLabel)
        
        bottomDetailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(referenceContainerView.snp.bottom).offset(layout.current.bottomLabelVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomLabelVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}
