//
//  LedgerTutorialInstructionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTutorialInstructionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var tutorialNumberView: LedgerTutorialNumberView = {
        let numberView = LedgerTutorialNumberView()
        numberView.setCornerRadius(16.0)
        return numberView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-gray-24"))
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        
        if !isDarkModeDisplay {
            applySmallShadow()
        }
    }
    
    override func prepareLayout() {
        setupTutorialNumberViewLayout()
        setupArrowImageViewLayout()
        setupTitleLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            removeShadows()
        } else {
            applySmallShadow()
        }
    }
}

extension LedgerTutorialInstructionView {
    private func setupTutorialNumberViewLayout() {
        addSubview(tutorialNumberView)
        
        tutorialNumberView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.numberSize)
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.iconSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(tutorialNumberView)
            make.leading.equalTo(tutorialNumberView.snp.trailing).offset(layout.current.horizontalInset)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(layout.current.titleHorizontalInset)
        }
    }
}

extension LedgerTutorialInstructionView {
    func setNumber(_ number: Int) {
        tutorialNumberView.setNumber(number)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension LedgerTutorialInstructionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let numberSize = CGSize(width: 32.0, height: 32.0)
        let titleHorizontalInset: CGFloat = -12.0
    }
}
