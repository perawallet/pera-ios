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
    
    private lazy var iconImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 12.0)))
            .withAlignment(.left)
            .withTextColor(.black)
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        setupIconImageViewLayout()
        setupTitleLabelLayout()
    }
}

extension LedgerTutorialInstructionView {
    private func setupIconImageViewLayout() {
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.iconHorizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.iconSize)
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(layout.current.titleHorizontalInset)
            make.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
}

extension LedgerTutorialInstructionView {
    func setIcon(_ icon: UIImage?) {
        iconImageView.image = icon
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension LedgerTutorialInstructionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let iconHorizontalInset: CGFloat = 14.0
        let iconSize = CGSize(width: 20.0, height: 20.0)
        let titleBottomInset: CGFloat = 21.0
        let titleHorizontalInset: CGFloat = 18.0
    }
}
