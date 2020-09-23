//
//  SingleSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 17.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SingleSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var selectionImageView = UIImageView(image: img("icon-check"))
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupSelectionImageViewLayout()
        setupTitleLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension SingleSelectionView {
    private func setupSelectionImageViewLayout() {
        addSubview(selectionImageView)
        
        selectionImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.equalTo(selectionImageView.snp.leading).offset(-layout.current.horizontalInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension SingleSelectionView {
    func bind(_ viewModel: SingleSelectionViewModel) {
        titleLabel.text = viewModel.title
        selectionImageView.isHidden = !viewModel.isSelected
    }
    
    func clear() {
        titleLabel.text = ""
        selectionImageView.isHidden = true
    }
}

extension SingleSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
    }
}
