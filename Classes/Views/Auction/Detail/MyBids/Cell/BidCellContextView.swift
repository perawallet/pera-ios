//
//  BidCellContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BidCellContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 10.0
        let topInset: CGFloat = 15.0
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 5.0
        let imageOffset: CGFloat = -3.0
        let lineTopOffset: CGFloat = 11.0
        let minimumOffset: CGFloat = -5.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgba(0.67, 0.67, 0.72, 0.3)
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 15.0)))
    }()
    
    private(set) lazy var bidStatusLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.turquois)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private lazy var maxPriceTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withText("auction-detail-max-price".localized)
    }()
    
    private(set) lazy var maxPriceLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
            .withTextColor(SharedColors.darkGray)
    }()
    
    private lazy var algosTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withText("auction-detail-min-potential-algos".localized)
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-algo-small-blue", isTemplate: true))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.turquois)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        algoIconImageView.tintColor = SharedColors.turquois
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.borderColor.cgColor
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAmountLabelLayout()
        setupBidStatusLabelLayout()
        setupSeparatorViewLayout()
        setupAlgosTitleLabelLayout()
        setupAlgosAmountLabelLayout()
        setupAlgoIconImageViewLayout()
        setupMaxPriceTitleLabelLayout()
        setupMaxPriceLabelLayout()
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupBidStatusLabelLayout() {
        addSubview(bidStatusLabel)
        
        bidStatusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(amountLabel)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.top.equalTo(amountLabel.snp.bottom).offset(layout.current.topInset)
        }
    }
    
    private func setupAlgosTitleLabelLayout() {
        addSubview(algosTitleLabel)
        
        algosTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.topInset)
        }
    }
    
    private func setupAlgosAmountLabelLayout() {
        addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(algosTitleLabel.snp.bottom).offset(layout.current.lineTopOffset)
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(algosAmountLabel.snp.leading).offset(layout.current.imageOffset)
            make.centerY.equalTo(algosAmountLabel)
        }
    }
    
    private func setupMaxPriceTitleLabelLayout() {
        addSubview(maxPriceTitleLabel)
        
        maxPriceTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.topInset)
        }
    }
    
    private func setupMaxPriceLabelLayout() {
        addSubview(maxPriceLabel)
        
        maxPriceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(maxPriceTitleLabel.snp.bottom).offset(layout.current.lineTopOffset)
            make.trailing.lessThanOrEqualTo(algoIconImageView.snp.leading).offset(layout.current.minimumOffset)
        }
    }
}
