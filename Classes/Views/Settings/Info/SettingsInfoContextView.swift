//
//  SettingsInfoContextView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsInfoContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.inputTitle)
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var detailImageView = UIImageView(image: img("icon-arrow"))
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupNameLabelLayout()
        setupDetailImageViewLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension SettingsInfoContextView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.nameOffset)
        }
    }
    
    private func setupDetailImageViewLayout() {
        addSubview(detailImageView)
        
        detailImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(detailImageView.snp.leading).offset(layout.current.detailOffset)
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

extension SettingsInfoContextView {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setDetail(_ detail: String?) {
        detailLabel.text = detail
    }
}

extension SettingsInfoContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let nameOffset: CGFloat = 12.0
        let detailOffset: CGFloat = -8.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
    }
}
