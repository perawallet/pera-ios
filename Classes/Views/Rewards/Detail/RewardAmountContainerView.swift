//
//  RewardAmountContainerView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardAmountContainerView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 9.0
        let separatorHeight: CGFloat = 1.0
        let separatorTopInset: CGFloat = 7.0
        let imageSize = CGSize(width: 16.0, height: 16.0)
        let imageTrailingInset: CGFloat = -4.0
        let amountVerticalInset: CGFloat = 12.0
        let amountCenterOffset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 10.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("algo-icon-accounts", isTemplate: true))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 24.0)))
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        layer.cornerRadius = 6.0
        backgroundColor = .white
        layer.borderColor = Colors.separatorColor.cgColor
        layer.borderWidth = 1.0
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSeparatorViewLayout()
        setupAmountLabelLayout()
        setupAlgoIconImageViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.separatorTopInset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.amountVerticalInset)
            make.centerX.equalToSuperview().offset(layout.current.amountCenterOffset)
            make.bottom.equalToSuperview().inset(layout.current.amountVerticalInset)
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)

        algoIconImageView.snp.makeConstraints { make in
            make.trailing.equalTo(amountLabel.snp.leading).offset(layout.current.imageTrailingInset)
            make.size.equalTo(layout.current.imageSize)
            make.centerY.equalTo(amountLabel)
        }
    }
}
