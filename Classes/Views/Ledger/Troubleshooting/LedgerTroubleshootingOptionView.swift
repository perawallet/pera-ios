//
//  LedgerTroubleshootingOptionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootingOptionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var numberLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(SharedColors.purple)
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(.black)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.warmWhite
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupNumberLabelLayout()
        setupTitleLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension LedgerTroubleshootingOptionView {
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.numberLeadingInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(layout.current.titleLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.titleTrailingInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
}

extension LedgerTroubleshootingOptionView {
    func setNumber(_ number: String) {
        numberLabel.text = number
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setAttributedTitle(_ attributedTitle: NSAttributedString) {
        titleLabel.attributedText = attributedTitle
    }
}

extension LedgerTroubleshootingOptionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let titleTrailingInset: CGFloat = 30.0
        let titleLeadingInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 13.0
        let numberLeadingInset: CGFloat = 22.0
        let verticalInset: CGFloat = 15.0
        let separatorHeight: CGFloat = 1.0
    }
}
