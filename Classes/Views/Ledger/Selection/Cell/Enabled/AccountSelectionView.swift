//
//  AccountSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    var state: State = .unselected {
        didSet {
            switch state {
            case .selected:
                containerView.layer.borderWidth = 2.0
                containerView.layer.borderColor = SharedColors.primary.cgColor
                containerView.backgroundColor = SharedColors.secondaryBackground
                
                if let titleView = stackView.arrangedSubviews.first as? LedgerAccountSelectionTitleView {
                    titleView.setSelectionImage(img("settings-node-active"))
                }
            case .unselected:
                containerView.layer.borderWidth = 0.0
                containerView.backgroundColor = SharedColors.secondaryBackground
                
                if let titleView = stackView.arrangedSubviews.first as? LedgerAccountSelectionTitleView {
                    titleView.setSelectionImage(img("settings-node-inactive"))
                }
            case .disabled:
                containerView.layer.borderWidth = 0.0
                containerView.backgroundColor = SharedColors.disabledBackground
            }
        }
    }
    
    private lazy var containerView = UIView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = SharedColors.secondaryBackground
        containerView.layer.cornerRadius = 12.0
        containerView.layer.masksToBounds = true
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupStackViewLayout()
    }
}

extension AccountSelectionView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupStackViewLayout() {
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }
}

extension AccountSelectionView {
    func addView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    func clear() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension AccountSelectionView {
    enum State {
        case selected
        case unselected
        case disabled
    }
}

extension AccountSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackInitialHeight: CGFloat = 118.0
        let horizontalInset: CGFloat = 20.0
    }
}
