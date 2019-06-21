//
//  DepositTypeView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DepositTypeView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 15.0
        let imageSize = CGSize(width: 45.0, height: 45.0)
        let labelTopInset: CGFloat = 2.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var typeBackgroundImageView: UIImageView = {
        let imageView = UIImageView(image: img("fund-oval-bg", isTemplate: true))
        imageView.tintColor = SharedColors.softGray
        return imageView
    }()
    
    private(set) lazy var typeImageView = UIImageView()
    
    private(set) lazy var typeTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
    }()
    
    private(set) lazy var amountLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 11.0)))
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 6.0
        layer.borderWidth = 1.0
        layer.borderColor = SharedColors.softGray.cgColor
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTypeBackgroundImageViewLayout()
        setupTypeImageViewLayout()
        setupTypeTitleLabelLayout()
        setupAmountLabelLayout()
    }
    
    private func setupTypeBackgroundImageViewLayout() {
        addSubview(typeBackgroundImageView)
        
        typeBackgroundImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupTypeImageViewLayout() {
        typeBackgroundImageView.addSubview(typeImageView)
        
        typeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTypeTitleLabelLayout() {
        addSubview(typeTitleLabel)
        
        typeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(typeBackgroundImageView.snp.bottom).offset(layout.current.labelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(typeTitleLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: API
    
    func set(selected isSelected: Bool) {
        if isSelected {
            typeBackgroundImageView.tintColor = SharedColors.blue
            typeTitleLabel.textColor = SharedColors.blue
            amountLabel.textColor = SharedColors.blue
            layer.borderColor = SharedColors.blue.cgColor
        } else {
            typeBackgroundImageView.tintColor = SharedColors.softGray
            typeTitleLabel.textColor = SharedColors.darkGray
            amountLabel.textColor = SharedColors.darkGray
            layer.borderColor = SharedColors.softGray.cgColor
        }
    }
}
