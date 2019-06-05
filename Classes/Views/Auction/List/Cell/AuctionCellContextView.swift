//
//  AuctionCellContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionCellContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let leadingInset: CGFloat = 30.0
        let topInset: CGFloat = 20.0
        let trailingInset: CGFloat = 25.0
        let separatorInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let verticalInset: CGFloat = 10.0
        let imageOffset: CGFloat = -3.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private lazy var dateTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .semiBold(size: 12.0)))
            .withText("auction-date-title".localized)
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withTextColor(SharedColors.black)
            .withLine(.contained)
    }()
    
    private lazy var algosTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .semiBold(size: 12.0)))
            .withText("auction-algos-sold-title".localized)
    }()
    
    private lazy var algoIconImageView = UIImageView(image: img("icon-algo-small-blue"))
    
    private(set) lazy var algosAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.turquois)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupDateTitleLabelLayout()
        setupDateLabelLayout()
        setupAlgosTitleLabelLayout()
        setupAlgosAmountLabelLayout()
        setupAlgoIconImageViewLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupDateTitleLabelLayout() {
        addSubview(dateTitleLabel)
        
        dateTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupAlgosTitleLabelLayout() {
        addSubview(algosTitleLabel)
        
        algosTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupAlgosAmountLabelLayout() {
        addSubview(algosAmountLabel)
        
        algosAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.top.equalTo(algosTitleLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(algosAmountLabel.snp.leading).offset(layout.current.imageOffset)
            make.centerY.equalTo(algosAmountLabel)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}
