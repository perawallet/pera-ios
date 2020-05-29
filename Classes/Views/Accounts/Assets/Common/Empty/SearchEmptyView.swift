//
//  SearchEmptyView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SearchEmptyView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.inputTitle)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
    }
}

extension SearchEmptyView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.topInset)
        }
    }
}

extension SearchEmptyView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String) {
        detailLabel.text = detail
    }
}

extension SearchEmptyView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 48.0
        let topInset: CGFloat = 12.0
    }
}
