//
//  NodeSettingsHeaderView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NodeSettingsHeaderView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageTopInset: CGFloat = 70.0
        let topInset: CGFloat = 26.0
        let separatorHeight: CGFloat = 1.0
        let verticalInset: CGFloat = 60.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.94, 0.94, 0.94)
    }
    
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
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in            make.top.equalToSuperview().inset(layout.current.imageTopInset)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(50)
        }
        
        setImage("icon-server", active: true)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.verticalInset)
        }
        
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    func setImage(_ image: String, active: Bool) {
        imageView.tintColor = active ? SharedColors.purple : SharedColors.softGray
        
        imageView.image = img(image, isTemplate: true)
    }
}
