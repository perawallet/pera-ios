//
//  LedgerAccountSelectionRekeyedInfoView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionRekeyedInfoView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var addressContainerView = UIView()
    
    private lazy var addressLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(SharedColors.primaryText)
    }()

    override func configureAppearance() {
        backgroundColor = SharedColors.disabledBackground
        addressContainerView.layer.cornerRadius = 12.0
        addressContainerView.backgroundColor = SharedColors.white
        addressContainerView.applyMediumShadow()
    }
        
    override func prepareLayout() {
        setupAddressContainerViewLayout()
        setupAddressLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addressContainerView.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
    }
}

extension LedgerAccountSelectionRekeyedInfoView {
    private func setupAddressContainerViewLayout() {
        addSubview(addressContainerView)
        
        addressContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview()
        }
    }
        
    private func setupAddressLabelLayout() {
        addressContainerView.addSubview(addressLabel)
            
        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension LedgerAccountSelectionRekeyedInfoView {
    func setRekeyedAddress(_ address: NSAttributedString?) {
        addressLabel.attributedText = address
    }
}

extension LedgerAccountSelectionRekeyedInfoView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 16.0
    }
}
