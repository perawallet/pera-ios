//
//  NodeSettingsHeaderView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NodeSettingsHeaderView: BaseView {
    
    private lazy var imageViewContainer: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = layout.current.containerHeight / 2
        return containerView
    }()
    
    private lazy var imageView: UIImageView = {
        UIImageView()
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.black)
            .withAlignment(.center)
            .withLine(.multi(2))
            .withText("node-settings-subtitle".localized)
    }()
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let containerHeight: CGFloat = 150.0
        let topInset: CGFloat = 20.0
        let verticalInset: CGFloat = 60.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addSubview(imageViewContainer)
        
        imageViewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(layout.current.containerHeight)
        }
        
        imageViewContainer.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(50)
        }
        
        setImage("icon-server", active: true)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageViewContainer.snp.bottom).offset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    func setImage(_ image: String, active: Bool) {
        imageView.tintColor = active ? SharedColors.purple : SharedColors.softGray
        
        imageView.image = img(image, isTemplate: true)
    }
}
