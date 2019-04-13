//
//  SettingsToggleContextView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SettingsToggleContextViewDelegate: class {
    func settingsToggle(_ toggle: Toggle, didChangeValue value: Bool)
}

class SettingsToggleContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 25.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: SettingsToggleContextViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0)))
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
        setupNameLabelLayout()
        setupToggleLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupToggleLayout() {
        addSubview(toggle)
        
        toggle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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
        delegate?.settingsToggle(toggle, didChangeValue: toggle.isOn)
    }
}
