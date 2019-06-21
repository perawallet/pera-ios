//
//  DepositTypeSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol DepositTypeSelectionViewDelegate: class {
    
    func depositTypeSelectionView(_ depositTypeSelectionView: DepositTypeSelectionView, didSelect depositType: DepositType)
}

class DepositTypeSelectionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 25.0
        let typeViewInset: CGFloat = 10.0
        let depositTypeViewSize = CGSize(width: (UIScreen.main.bounds.width - 60.0) / 3, height: 110.0 * verticalScale)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: DepositTypeSelectionViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var usdDepositTypeView: DepositTypeView = {
        let view = DepositTypeView()
        view.isUserInteractionEnabled = true
        view.typeTitleLabel.text = "deposit-usd".localized
        view.typeImageView.image = img("icon-dollar")
        view.amountLabel.isHidden = true
        return view
    }()
    
    private(set) lazy var ethDepositTypeView: DepositTypeView = {
        let view = DepositTypeView()
        view.isUserInteractionEnabled = true
        view.typeTitleLabel.text = "deposit-eth".localized
        view.typeImageView.image = img("icon-eth")
        return view
    }()
    
    private(set) lazy var btcDepositTypeView: DepositTypeView = {
        let view = DepositTypeView()
        view.isUserInteractionEnabled = true
        view.typeTitleLabel.text = "deposit-btc".localized
        view.typeImageView.image = img("icon-btc")
        return view
    }()
    
    // MARK: Gestures
    
    private lazy var usdDepositTypeViewGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToUSDDepositTypeViewTapped)
    )
    
    private lazy var ethDepositTypeViewGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToETHDepositTypeViewTapped)
    )
    
    private lazy var btcDepositTypeViewGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToBTCDepositTypeViewTapped)
    )
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        super.setListeners()
        
        usdDepositTypeView.addGestureRecognizer(usdDepositTypeViewGestureRecognizer)
        ethDepositTypeView.addGestureRecognizer(ethDepositTypeViewGestureRecognizer)
        btcDepositTypeView.addGestureRecognizer(btcDepositTypeViewGestureRecognizer)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupUSDDepositTypeViewLayout()
        setupETHDepositTypeViewLayout()
        setupBTCDepositTypeViewLayout()
    }

    private func setupUSDDepositTypeViewLayout() {
        addSubview(usdDepositTypeView)
        
        usdDepositTypeView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.size.equalTo(layout.current.depositTypeViewSize)
        }
    }
    
    private func setupETHDepositTypeViewLayout() {
        addSubview(ethDepositTypeView)
        
        ethDepositTypeView.snp.makeConstraints { make in
            make.leading.equalTo(usdDepositTypeView.snp.trailing).offset(layout.current.typeViewInset)
            make.top.equalTo(usdDepositTypeView)
            make.size.equalTo(usdDepositTypeView)
        }
    }
    
    private func setupBTCDepositTypeViewLayout() {
        addSubview(btcDepositTypeView)
        
        btcDepositTypeView.snp.makeConstraints { make in
            make.leading.equalTo(ethDepositTypeView.snp.trailing).offset(layout.current.typeViewInset)
            make.top.equalTo(usdDepositTypeView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(usdDepositTypeView)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToUSDDepositTypeViewTapped() {
        usdDepositTypeView.set(selected: true)
        ethDepositTypeView.set(selected: false)
        btcDepositTypeView.set(selected: false)
        
        delegate?.depositTypeSelectionView(self, didSelect: .usd)
    }
    
    @objc
    private func notifyDelegateToETHDepositTypeViewTapped() {
        usdDepositTypeView.set(selected: false)
        ethDepositTypeView.set(selected: true)
        btcDepositTypeView.set(selected: false)
        
        delegate?.depositTypeSelectionView(self, didSelect: .eth)
    }
    
    @objc
    private func notifyDelegateToBTCDepositTypeViewTapped() {
        usdDepositTypeView.set(selected: false)
        ethDepositTypeView.set(selected: false)
        btcDepositTypeView.set(selected: true)
        
        delegate?.depositTypeSelectionView(self, didSelect: .btc)
    }
}
