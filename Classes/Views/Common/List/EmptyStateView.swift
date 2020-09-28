//
//  AccountsEmptyStateView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class EmptyStateView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView(image: image)
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withText(title)
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAttributedText(subtitle.attributed([.lineSpacing(1.2)]))
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.gray800)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()
    
    private var image: UIImage?
    private var title: String = ""
    private var subtitle: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(image: UIImage?, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        imageView.contentMode = .scaleAspectFill
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupSubtitleLabelLayout()
    }
}

extension EmptyStateView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(50.0)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).inset(layout.current.titleTopInset)
            make.height.lessThanOrEqualTo(layout.current.maximumImageHeight)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension EmptyStateView {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setSubtitle(_ subtitle: String) {
        subtitleLabel.text = subtitle
    }
}

extension EmptyStateView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 40.0 * horizontalScale
        let maximumImageHeight: CGFloat = 200.0
        let titleTopInset: CGFloat = 40.0
        let subtitleTopInset: CGFloat = 12.0 * verticalScale
    }
}
