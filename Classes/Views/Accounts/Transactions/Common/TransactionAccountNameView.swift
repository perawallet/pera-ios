//
//  TransactionAccountNameView.swift

import UIKit

class TransactionAccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var accountNameView = AccountNameView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = .clear
        titleLabel.text = "title-account".localized
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionAccountNameView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        accountNameView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.minimumOffset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension TransactionAccountNameView {
    func bind(_ viewModel: AccountNameViewModel?) {
        if let viewModel = viewModel {
            accountNameView.bind(viewModel)
        }
    }

    func setAccountImage(_ image: UIImage?) {
        accountNameView.setAccountImage(image)
    }
    
    func setAccountName(_ name: String?) {
        accountNameView.setAccountName(name)
    }
}

extension TransactionAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let minimumOffset: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
    }
}
