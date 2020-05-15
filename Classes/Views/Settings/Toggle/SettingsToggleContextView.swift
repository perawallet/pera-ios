//
//  SettingsToggleContextView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsToggleContextView: BaseView {
    
    let layout = Layout<LayoutConstants>()
    
    weak var delegate: SettingsToggleContextViewDelegate?
    
    var indexPath: IndexPath?
    
    private lazy var imageView = UIImageView()
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var toggle = Toggle()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func setListeners() {
        toggle.addTarget(self, action: #selector(didChangeToggle(_:)), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupNameLabelLayout()
        setupToggleLayout()
        setupSeparatorViewLayout()
    }
}

extension SettingsToggleContextView {
    @objc
    fileprivate func didChangeToggle(_ toggle: Toggle) {
        guard let indexPath = self.indexPath else {
            return
        }
        
        delegate?.settingsToggle(toggle, didChangeValue: toggle.isOn, forIndexPath: indexPath)
    }
}

extension SettingsToggleContextView {
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
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.nameOffset)
        }
    }
    
    private func setupToggleLayout() {
        addSubview(toggle)
        
        toggle.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(12.0)
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

extension SettingsToggleContextView {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}

extension SettingsToggleContextView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let nameOffset: CGFloat = 12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
    }
}

protocol SettingsToggleContextViewDelegate: class {
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool, forIndexPath indexPath: IndexPath)
}
