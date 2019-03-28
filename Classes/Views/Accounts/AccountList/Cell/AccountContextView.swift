//
//  AccountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let imageViewRightInset: CGFloat = -5.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.black)
    }()
    
    private(set) lazy var algoImageView = UIImageView(image: img("algo-icon-small", isTemplate: true))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel().withLine(.single).withAlignment(.right).withFont(UIFont.font(.opensans, withWeight: .bold(size: 15.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupAmountLabelLayout()
        setupAlgoImageViewLayout()
        setupNameLabelLayout()
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupAlgoImageViewLayout() {
        addSubview(algoImageView)
        
        algoImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(amountLabel.snp.leading).offset(layout.current.imageViewRightInset)
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualTo(algoImageView.snp.leading)
        }
    }
}
