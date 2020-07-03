//
//  RangeSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RangeSelectionView: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.subtitleText)
    }()
    
    private lazy var imageView = UIImageView()
    
    private lazy var dateLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    private lazy var separatorView = UIImageView(image: img("img-custom-range-separator"))
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupDateLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension RangeSelectionView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.labelOffset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelOffset)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalTo(imageView)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.labelOffset)
        }
    }
}

extension RangeSelectionView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setDate(_ date: String) {
        dateLabel.text = date
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            imageView.tintColor = SharedColors.primary
            separatorView.image = img("img-custom-range-separator-selected")
        } else {
            imageView.tintColor = SharedColors.gray500
            separatorView.image = img("img-custom-range-separator")
        }
    }
}

extension RangeSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelOffset: CGFloat = 8.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
