//
//  RewardView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardTotalAmountView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let imageInset: CGFloat = 13.0
        let imageSize = CGSize(width: 12.0, height: 12.0)
        let horizontalInset: CGFloat = 25.0
        let verticalInset: CGFloat = 15.0
        let amountLeadingInset: CGFloat = 3.0
        let titleLeadingInset: CGFloat = 5.0
        let trailingInset: CGFloat = 17.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private lazy var infoImageView = UIImageView(image: img("icon-info-purple"))

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 10.0)))
            .withTextColor(SharedColors.purple)
            .withLine(.single)
            .withAlignment(.left)
            .withAttributedText("total-rewards-earned-title".localized.attributed([.letterSpacing(1.10)]))
    }()
    
    private(set) lazy var algosAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.amountLabel.textAlignment = .right
        view.amountLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 12.0))
        view.signLabel.isHidden = true
        view.amountLabel.text = 0.0.toDecimalStringForLabel
        view.amountLabel.textColor = SharedColors.purple
        view.algoIconImageView.image = img("icon-algo-small-purple")
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupSeparatorViewLayout()
        setupInfoImageViewLayout()
        setupTitleLabelLayout()
        setupAlgosAmountViewLayout()
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupInfoImageViewLayout() {
        addSubview(infoImageView)
        
        infoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.imageInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoImageView.snp.trailing).offset(layout.current.titleLeadingInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAlgosAmountViewLayout() {
        addSubview(algosAmountView)
        
        algosAmountView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.amountLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.centerY.equalTo(titleLabel)
        }
    }
}
