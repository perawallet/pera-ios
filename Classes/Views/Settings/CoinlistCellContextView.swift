//
//  CoinlistCellContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol CoinlistCellContextViewDelegate: class {
    
    func coinlistCellContextViewDidTapActionButton(_ coinlistCellContextView: CoinlistCellContextView)
}

class CoinlistCellContextView: BaseView {
    
    enum ActionMode {
        case connect
        case disconnect
    }
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 25.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: CoinlistCellContextViewDelegate?
    
    var actionMode: ActionMode = .connect {
        didSet {
            if actionMode == oldValue {
                return
            }
            
            switch actionMode {
            case .connect:
                actionButton.setTitle("settings-coinlist-connect".localized, for: .normal)
                actionButton.backgroundColor = SharedColors.purple.withAlphaComponent(0.1)
                actionButton.layer.borderColor = SharedColors.purple.cgColor
                actionButton.setTitleColor(SharedColors.purple, for: .normal)
            case .disconnect:
                actionButton.setTitle("settings-coinlist-disconnect".localized, for: .normal)
                actionButton.backgroundColor = SharedColors.orange.withAlphaComponent(0.1)
                actionButton.layer.borderColor = SharedColors.orange.cgColor
                actionButton.setTitleColor(SharedColors.orange, for: .normal)
            }
        }
    }
    
    // MARK: Components
    
    private(set) lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
    }()
    
    private(set) lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("settings-coinlist-connect".localized, for: .normal)
        button.backgroundColor = SharedColors.purple.withAlphaComponent(0.1)
        button.setTitleColor(SharedColors.purple, for: .normal)
        button.titleLabel?.font = UIFont.font(.avenir, withWeight: .demiBold(size: 12.0))
        button.layer.borderColor = SharedColors.purple.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 19.0
        return button
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupNameLabelLayout()
        setupActionButtonLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(161.0)
            make.height.equalTo(38.0)
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
    
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.coinlistCellContextViewDidTapActionButton(self)
    }
    
}
