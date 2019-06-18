//
//  PassPhraseVerifyView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseVerifyView: UIView {
    
    private(set) lazy var questionTitleLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 20.0)))
            .withTextColor(SharedColors.black)
            .withAlignment(NSTextAlignment.center)
    }()
    
    private(set) lazy var questionSubtitleLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withTextColor(SharedColors.purple)
            .withAlignment(NSTextAlignment.center)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension PassPhraseVerifyView {
    fileprivate func setupLayout() {
        addSubview(questionTitleLabel)
        questionTitleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(69 * verticalScale)
            maker.leading.trailing.equalToSuperview().inset(15)
        }
        
        addSubview(questionSubtitleLabel)
        questionSubtitleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(questionTitleLabel.snp.bottom).offset(16 * verticalScale)
            maker.leading.trailing.equalToSuperview().inset(15)
            maker.bottom.equalToSuperview().inset(20.0 * verticalScale)
        }
    }
}
