//
//  LedgerAccountDetailView.swift

import UIKit

class LedgerAccountDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withText("ledger-account-details-title".localized)
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var accountStackView = WrappedStackView()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var rekeyedAccountsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 12.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAccountStackViewLayout()
        setupSubtitleLabelLayout()
        setupRekeyedAccountsStackViewLayout()
    }
}

extension LedgerAccountDetailView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAccountStackViewLayout() {
        addSubview(accountStackView)
        
        accountStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.stackTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(accountStackView.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupRekeyedAccountsStackViewLayout() {
        addSubview(rekeyedAccountsStackView)
        
        rekeyedAccountsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.stackTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension LedgerAccountDetailView {
    func bind(_ viewModel: LedgerAccountDetailViewModel) {
        viewModel.assetViews.forEach { view in
            accountStackView.addArrangedSubview(view)
        }
        
        guard let rekeyedAccountViews = viewModel.rekeyedAccountViews else {
            return
        }
        
        subtitleLabel.text = viewModel.subtitle
        
        rekeyedAccountViews.forEach { view in
            rekeyedAccountsStackView.addArrangedSubview(view)
        }
    }
}

extension LedgerAccountDetailView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 24.0
        let stackTopInset: CGFloat = 12.0
        let subtitleTopInset: CGFloat = 40.0
    }
}
