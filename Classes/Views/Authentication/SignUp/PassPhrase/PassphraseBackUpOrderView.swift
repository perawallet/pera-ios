//
//  PassphraseBackUpOrderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseBackUpOrderView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let leadingInset: CGFloat = 2.0
        let centerOffset: CGFloat = -1.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var numberLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 9.0)))
            .withTextColor(SharedColors.purple)
            .withAlignment(.left)
    }()
    
    private(set) lazy var phraseLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withAlignment(.left)
        
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupNumberLabelLayout()
        setupPhraseLabelLayout()
    }
    
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupPhraseLabelLayout() {
        addSubview(phraseLabel)
        
        phraseLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(layout.current.centerOffset)
            make.leading.equalTo(numberLabel.snp.trailing).offset(layout.current.leadingInset)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
