//
//  DepositFundSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol DepositFundSelectionViewDelegate: class {
    
    func depositFundSelectionView(_ depositFundSelectionView: DepositFundSelectionView, didSelect depositType: DepositType)
}

class DepositFundSelectionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelBottomInset: CGFloat = 24.0
        let labelHorizontalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: DepositFundSelectionViewDelegate?
    
    private enum Colors {
        static let gray = rgb(0.58, 0.58, 0.58)
    }
    
    // MARK: Components
    
    private lazy var titleLabelView: DepositTransactionHeaderView = {
        let view = DepositTransactionHeaderView()
        view.titleLabel.textColor = SharedColors.darkGray
        view.titleLabel.text = "deposit-fund-view-title".localized
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var depositTypeSelectionView: DepositTypeSelectionView = {
        let view = DepositTypeSelectionView()
        return view
    }()
    
    private lazy var bottomExplanationLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.gray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("deposit-fund-convert-title".localized)
    }()
    
    // MARK: Setup
    
    override func linkInteractors() {
        depositTypeSelectionView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTitleLabelViewLayout()
        setupContainerViewLayout()
        setupDepositTypeSelectionViewLayout()
        setupBottomExplanationLabelLayout()
    }
    
    private func setupTitleLabelViewLayout() {
        addSubview(titleLabelView)
        
        titleLabelView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabelView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupDepositTypeSelectionViewLayout() {
        containerView.addSubview(depositTypeSelectionView)
        
        depositTypeSelectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func setupBottomExplanationLabelLayout() {
        containerView.addSubview(bottomExplanationLabel)
        
        bottomExplanationLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.labelBottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.labelHorizontalInset)
            make.centerX.equalToSuperview()
            make.top.equalTo(depositTypeSelectionView.snp.bottom)
        }
    }
}

// MARK: DepositTypeSelectionViewDelegate

extension DepositFundSelectionView: DepositTypeSelectionViewDelegate {
    
    func depositTypeSelectionView(_ depositTypeSelectionView: DepositTypeSelectionView, didSelect depositType: DepositType) {
        delegate?.depositFundSelectionView(self, didSelect: depositType)
    }
}
