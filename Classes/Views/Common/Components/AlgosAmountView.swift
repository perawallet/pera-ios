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
        let labelInset: CGFloat = 3.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    var mode: Mode = .normal(0.00) {
        didSet {
            
            updateAmountView()
        }
    }
    
    // MARK: Components
    
    private(set) lazy var signLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.opensans, withWeight: .bold(size: 16.0)))
    }()
    
    private(set) lazy var algoIconImageView = UIImageView(image: img("icon-algo-small-black"))
    
    private(set) lazy var amountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.opensans, withWeight: .bold(size: 16.0)))
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
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAlgoIconImageViewLayout() {
        addSubview(algoIconImageView)
        
        algoIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(signLabel.snp.trailing)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAmountLabelLayout() {
        addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(algoIconImageView.snp.trailing).offset(layout.current.labelInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    // MARK: Update
    
    private func updateAmountView() {
        switch mode {
        case let .normal(amount):
            signLabel.isHidden = true
            
            amountLabel.text = "\(amount)"
            amountLabel.textColor = SharedColors.black
            
            algoIconImageView.image = img("icon-algo-small-black")
        case let .positive(amount):
            signLabel.isHidden = false
            signLabel.text = "+"
            signLabel.textColor = SharedColors.green
            
            amountLabel.text = "\(amount)"
            amountLabel.textColor = SharedColors.green
            
            algoIconImageView.image = img("icon-algo-small-green")
        case let .negative(amount):
            signLabel.isHidden = false
            signLabel.text = "-"
            signLabel.textColor = SharedColors.blue
            
            amountLabel.text = "\(amount)"
            amountLabel.textColor = SharedColors.blue
            
            algoIconImageView.image = img("icon-algo-small-blue")
        }
    }
}

// MARK: Mode

extension AlgosAmountView {
    
    enum Mode {
        case normal(Double)
        case positive(Double)
        case negative(Double)
    }
}
