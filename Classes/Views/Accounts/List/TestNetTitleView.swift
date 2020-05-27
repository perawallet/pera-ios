//
//  TestNetTitleView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TestNetTitleView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel().withFont(UIFont.font(withWeight: .semiBold(size: 16.0))).withTextColor(SharedColors.primaryText)
    }()
    
    private lazy var testNetLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 10.0)))
            .withTextColor(SharedColors.primaryButtonTitle)
            .withAlignment(.center)
            .withText("title-testnet".localized)
        label.backgroundColor = SharedColors.verified
        label.layer.cornerRadius = 12.0
        label.layer.masksToBounds = true
        return label
    }()
    
    init(title: String?) {
        super.init(frame: .zero)
        titleLabel.text = title
    }
    
    override func prepareLayout() {
        setupTestNetLabelLayout()
        setupTitleLabelLayout()
    }
}

extension TestNetTitleView {
    private func setupTestNetLabelLayout() {
        addSubview(testNetLabel)
        
        testNetLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.size.equalTo(layout.current.testNetLabelSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(testNetLabel.snp.leading).offset(layout.current.titleOffset)
        }
    }
}

extension TestNetTitleView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension TestNetTitleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleOffset: CGFloat = -8.0
        let testNetLabelSize = CGSize(width: 63.0, height: 24.0)
    }
}
