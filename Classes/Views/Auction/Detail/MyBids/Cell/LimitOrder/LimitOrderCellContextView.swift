//
//  LimitOrderCellContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol LimitOrderCellContextViewDelegate: class {
    
    func limitOrderCellContextViewDidTapRetractButton(_ limitOrderCellContextView: LimitOrderCellContextView)
}

class LimitOrderCellContextView: BidCellContextView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 17.0
        let trailingInset: CGFloat = 12.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var retractButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-retract"), for: .normal)
        return button
    }()
    
    weak var delegate: LimitOrderCellContextViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        super.setListeners()
        
        retractButton.addTarget(self, action: #selector(notifyDelegateToRetractButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        bidStatusLabel.isHidden = true
        
        setupRetractButtonLayout()
    }
    
    private func setupRetractButtonLayout() {
        addSubview(retractButton)
        
        retractButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToRetractButtonTapped() {
        delegate?.limitOrderCellContextViewDidTapRetractButton(self)
        
        retractButton.isHidden = true
        bidStatusLabel.isHidden = false
        
        bidStatusLabel.textColor = SharedColors.orange
        bidStatusLabel.text = BidStatus.retracted.rawValue
        algoIconImageView.tintColor = SharedColors.orange
        algosAmountLabel.textColor = SharedColors.orange
    }
}
