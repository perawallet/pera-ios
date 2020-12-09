//
//  DateWithTextImageView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class DateWithTextImageView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .extraBold(size: 10.0)))
            .withTextColor(Colors.Text.secondary)
        label.isHidden = true
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupDayLabelLayout()
    }
}

extension DateWithTextImageView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.imageSize)
            make.edges.equalToSuperview()
        }
    }
    
    private func setupDayLabelLayout() {
        addSubview(dayLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.leading.trailing.equalToSuperview().inset(layout.current.labelInset)
        }
    }
}

extension DateWithTextImageView {
    func setImage(_ image: UIImage?) {
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.Text.secondary
    }
    
    func setDate(_ date: String) {
        dayLabel.isHidden = false
        dayLabel.text = date
    }
    
    func setSelected() {
        dayLabel.textColor = Colors.General.selected
        imageView.tintColor = Colors.General.selected
    }
    
    func setDeselected() {
        dayLabel.textColor = Colors.Text.secondary
        imageView.tintColor = Colors.Text.secondary
    }
    
    func setDayLabelHidden(_ isHidden: Bool) {
        dayLabel.isHidden = isHidden
    }
}

extension DateWithTextImageView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelInset: CGFloat = 4.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
