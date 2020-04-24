//
//  LedgerTutorialNumberView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTutorialNumberView: BaseView {
    
    private lazy var numberLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(.publicSans, withWeight: .medium(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(color("secondaryText"))
    }()
    
    override func configureAppearance() {
        backgroundColor = color("gray100")
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupNumberLabelLayout()
    }
}

extension LedgerTutorialNumberView {
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }
}

extension LedgerTutorialNumberView {
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func setNumber(_ number: Int) {
        numberLabel.text = "\(number)"
    }
}
