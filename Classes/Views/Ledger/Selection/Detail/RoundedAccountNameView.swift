//
//  RoundedAccountNameView.swift

import UIKit

class RoundedAccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var accountNameView = AccountNameView()
    
    override func configureAppearance() {
        layer.cornerRadius = 12.0
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupAccountNameViewLayout()
    }
}

extension RoundedAccountNameView {
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension RoundedAccountNameView {
    func bind(_ viewModel: AuthAccountNameViewModel) {
        accountNameView.bind(viewModel)
    }
    
    func bind(_ viewModel: AccountNameViewModel) {
        accountNameView.bind(viewModel)
    }
}

extension RoundedAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
    }
}
