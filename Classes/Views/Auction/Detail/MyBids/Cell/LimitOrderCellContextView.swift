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
        let trailingInset: CGFloat = 7.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let backgroundColor = rgba(0.0, 0.46, 1.0, 0.1)
        static let separatorColor = rgba(0.0, 0.46, 1.0, 0.2)
    }
    
    // MARK: Components
    
    private(set) lazy var retractButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 4.5, y: 0.0), title: CGPoint(x: -4.5, y: 0.0))
        
        let button = AlignedButton(style: .imageRight(positions))
        button.setImage(img("icon-retract"), for: .normal)
        button.setTitle("auction-detail-retract-title".localized, for: .normal)
        button.setTitleColor(SharedColors.red, for: .normal)
        button.titleLabel?.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))
        return button
    }()
    
    weak var delegate: LimitOrderCellContextViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        super.setListeners()
        
        retractButton.addTarget(self, action: #selector(notifyDelegateToRetractButtonTapped), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.backgroundColor
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.separatorColor.cgColor
        
        separatorView.backgroundColor = Colors.separatorColor
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
    }
}
