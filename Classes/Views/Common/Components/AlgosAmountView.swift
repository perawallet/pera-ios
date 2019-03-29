//
//  AlgosAmountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlgosAmountView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var signLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0)))
            .withText("accounts-tranaction-empty-text".localized)
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-transaction-empty-green"))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0)))
            .withText("accounts-tranaction-empty-text".localized)
    }()

    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupSignLabelLayout()
        setupAlgoIconImageViewLayout()
        setupAmountLabelLayout()
    }
    
    private func setupSignLabelLayout() {
        addSubview(signLabel)
        
        signLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            
        }
    }
}
