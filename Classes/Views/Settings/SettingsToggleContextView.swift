//
//  SettingsToggleContextView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SettingsToggleContextViewDelegate: class {
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool, forIndexPath indexPath: IndexPath)
    func settingsToggleDidTapEdit(forIndexPath indexPath: IndexPath)
}

class SettingsToggleContextView: BaseView {
    
    struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let editButtonInset: CGFloat = 15.0
        let horizontalInset: CGFloat = 25.0
        let horizontalOffset: CGFloat = 10.0
    }
    
    let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: SettingsToggleContextViewDelegate?
    
    var indexPath: IndexPath?
    
    // MARK: Components
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapEditButton(_:)), for: .touchUpInside)
        button.setImage(img("icon-server-edit"), for: .normal)
        return button
    }()
    
    private(set) lazy var toggle: Toggle = {
        Toggle()
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        toggle.addTarget(self, action: #selector(didChangeToggle(_:)), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        
        setupImageViewLayout()
        setupNameLabelLayout()
        setupToggleLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupImageViewLayout() {
        addSubview(editButton)
        
        editButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.editButtonInset)
            make.width.height.equalTo(44)
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(editButton)
            make.leading.equalTo(editButton.snp.trailing).offset(layout.current.horizontalOffset)
        }
    }
    
    private func setupToggleLayout() {
        addSubview(toggle)
        
        toggle.snp.makeConstraints { make in
            make.centerY.equalTo(editButton)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.lessThanOrEqualTo(nameLabel.snp.trailing).offset(15.0)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - Actions
extension SettingsToggleContextView {
    @objc
    fileprivate func didChangeToggle(_ toggle: Toggle) {
        guard let indexPath = self.indexPath else {
            return
        }
        
        delegate?.settingsToggle(toggle, didChangeValue: toggle.isOn, forIndexPath: indexPath)
    }
    
    @objc
    fileprivate func didTapEditButton(_ button: UIButton) {
        guard let indexPath = self.indexPath else {
            return
        }
        
        delegate?.settingsToggleDidTapEdit(forIndexPath: indexPath)
    }
}
