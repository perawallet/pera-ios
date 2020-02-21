//
//  NoInternetConnectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NoInternetConnectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView(image: img("img-no-internet-connection"))
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.borderWidth = 0.8
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 16.0)))
            .withTextColor(SharedColors.purple)
            .withAlignment(.center)
            .withText("internet-connection-error-title".localized)
            .withLine(.single)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.black)
            .withAlignment(.center)
            .withText("internet-connection-error-detail".localized)
            .withLine(.contained)
    }()
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupBackgroundViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
}

extension NoInternetConnectionView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupBackgroundViewLayout() {
        addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        backgroundView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        backgroundView.addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.subtitleBottomInset)
        }
    }
}

extension NoInternetConnectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewTopInset: CGFloat = 100.0
        let verticalInset: CGFloat = 25.0
        let horizontalInset: CGFloat = 35.0
        let subtitleTopInset: CGFloat = 18.0
        let subtitleHorizontalInset: CGFloat = 20.0
        let subtitleBottomInset: CGFloat = 30.0
    }
}

extension NoInternetConnectionView {
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
