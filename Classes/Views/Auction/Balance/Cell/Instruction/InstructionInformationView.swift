//
//  InstructionInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class InstructionInformationView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 15.0
        let horizontalInset: CGFloat = 20.0
        let labelTopInset: CGFloat = 2.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(.black)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTitleLabelLayout()
        setupDetailLabelLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.labelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}
