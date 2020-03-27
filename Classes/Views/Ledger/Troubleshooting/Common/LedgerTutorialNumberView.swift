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
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
    }()
    
    override func configureAppearance() {
        backgroundColor = rgb(0.95, 0.95, 0.96)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }
}

// MARK: API
extension LedgerTutorialNumberView {
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func setNumber(_ number: Int) {
        numberLabel.text = "\(number)"
    }
}
