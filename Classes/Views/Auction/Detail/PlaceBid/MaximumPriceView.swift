//
//  MaximumPriceView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class MaximumPriceView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 17.0
        let titleTopInset: CGFloat = 18.0
        let separatorInset: CGFloat = 38.0
        let separatorHeight: CGFloat = 1.0
        let verticalSeparatorTopInset: CGFloat = 10.0
        let verticalSeparatorHeight: CGFloat = 30.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgba(0.67, 0.67, 0.72, 0.3)
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private lazy var maxPriceTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("auction-detail-max-price".localized)
    }()
    
    private lazy var verticalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private lazy var priceAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.turquois)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("$5.00")
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.borderColor.cgColor
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBidAmountTitleLabelLayout()
        setupVerticalSeparatorViewLayout()
        setupBidAmountLabelLayout()
    }
    
    private func setupBidAmountTitleLabelLayout() {
        addSubview(maxPriceTitleLabel)
        
        maxPriceTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
    }
    
    private func setupVerticalSeparatorViewLayout() {
        addSubview(verticalSeparatorView)
        
        verticalSeparatorView.snp.makeConstraints { make in
            make.leading.equalTo(maxPriceTitleLabel.snp.trailing).offset(layout.current.separatorInset)
            make.width.equalTo(layout.current.separatorHeight)
            make.height.equalTo(layout.current.verticalSeparatorHeight)
            make.top.equalToSuperview().inset(layout.current.verticalSeparatorTopInset)
        }
    }
    
    private func setupBidAmountLabelLayout() {
        addSubview(priceAmountLabel)
        
        priceAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
    }
}
