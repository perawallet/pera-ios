//
//  LedgerAccountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerAccountViewDelegate?
    
    var state: State = .unselected {
        didSet {
            switch state {
            case .selected:
                accountStackView.containerView.layer.borderWidth = 2.0
                accountStackView.containerView.layer.borderColor = Colors.General.selected.cgColor
            case .unselected:
                accountStackView.containerView.layer.borderWidth = 0.0
            }
        }
    }
    
    private lazy var accountStackView: WrappedStackView = {
        let accountStackView = WrappedStackView()
        accountStackView.stackView.isUserInteractionEnabled = true
        return accountStackView
    }()
    
    override func prepareLayout() {
        setupAccountStackViewLayout()
    }
}

extension LedgerAccountView {
    private func setupAccountStackViewLayout() {
        addSubview(accountStackView)
        
        accountStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview()
        }
    }
}

extension LedgerAccountView {
    func clear() {
        accountStackView.clear()
    }
    
    func bind(_ viewModel: LedgerAccountNameViewModel) {
        if let nameView = accountStackView.stackView.arrangedSubviews.first as? LedgerAccountNameView {
            nameView.bind(viewModel)
        }
    }
    
    func bind(_ viewModel: LedgerAccountSelectionViewModel) {
        state = viewModel.isSelected ? .selected : .unselected
        
        viewModel.subviews.forEach { view in
            if let ledgerAccountNameView = view as? LedgerAccountNameView {
                ledgerAccountNameView.delegate = self
            }
            accountStackView.addArrangedSubview(view)
        }
    }
}

extension LedgerAccountView: LedgerAccountNameViewDelegate {
    func ledgerAccountNameViewDidOpenInfo(_ ledgerAccountNameView: LedgerAccountNameView) {
        delegate?.ledgerAccountViewDidOpenMoreInfo(self)
    }
}

extension LedgerAccountView {
    enum State {
        case selected
        case unselected
    }
}

extension LedgerAccountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackInitialHeight: CGFloat = 118.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol LedgerAccountViewDelegate: class {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountView)
}
