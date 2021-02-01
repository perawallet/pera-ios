//
//  AccountTypeSelectionView.swift

import UIKit

class AccountTypeSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountTypeSelectionViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.0
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var termsAndConditionsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.textAlignment = .center
        textView.linkTextAttributes = [
            .foregroundColor: Colors.Text.link,
            .underlineColor: UIColor.clear,
            .font: UIFont.font(withWeight: .regular(size: 14.0))
        ]
        
        let centerParagraphStyle = NSMutableParagraphStyle()
        centerParagraphStyle.alignment = .center
        
        textView.bindHtml(
            "introduction-title-terms-and-services".localized,
            with: [
                .font: UIFont.font(withWeight: .regular(size: 14.0)),
                .foregroundColor: Colors.Text.tertiary,
                .paragraphStyle: centerParagraphStyle
            ]
        )
        return textView
    }()
    
    private lazy var createNewAccountView = AccountTypeView()
    
    private lazy var watchAccountView = AccountTypeView()
    
    private lazy var recoverAccountView = AccountTypeView()
    
    private lazy var pairAccountView = AccountTypeView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }
    
    override func setListeners() {
        createNewAccountView.addTarget(self, action: #selector(notifyDelegateToSelectCreateNewAccount), for: .touchUpInside)
        watchAccountView.addTarget(self, action: #selector(notifyDelegateToSelectWatchAccount), for: .touchUpInside)
        recoverAccountView.addTarget(self, action: #selector(notifyDelegateToSelectRecoverAccount), for: .touchUpInside)
        pairAccountView.addTarget(self, action: #selector(notifyDelegateToSelectPairAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTermsAndConditionsTextViewLayout()
        setupStackViewLayout()
    }
}

extension AccountTypeSelectionView {
    @objc
    private func notifyDelegateToSelectCreateNewAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .create)
    }
    
    @objc
    private func notifyDelegateToSelectWatchAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .watch)
    }
    
    @objc
    private func notifyDelegateToSelectRecoverAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .recover)
    }
    
    @objc
    private func notifyDelegateToSelectPairAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .pair)
    }
}

extension AccountTypeSelectionView {
    private func setupTermsAndConditionsTextViewLayout() {
        addSubview(termsAndConditionsTextView)
        
        termsAndConditionsTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupStackViewLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.lessThanOrEqualTo(termsAndConditionsTextView.snp.top).offset(-layout.current.verticalInset)
        }
        
        stackView.addArrangedSubview(createNewAccountView)
        stackView.addArrangedSubview(watchAccountView)
        stackView.addArrangedSubview(recoverAccountView)
        stackView.addArrangedSubview(pairAccountView)
    }
}

extension AccountTypeSelectionView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.accountTypeSelectionView(self, didOpen: URL)
        return false
    }
}

extension AccountTypeSelectionView {
    func configureCreateNewAccountView(with viewModel: AccountTypeViewModel) {
        createNewAccountView.bind(viewModel)
    }
    
    func configureWatchAccountView(with viewModel: AccountTypeViewModel) {
        watchAccountView.bind(viewModel)
    }
    
    func configureRecoverAccountView(with viewModel: AccountTypeViewModel) {
        recoverAccountView.bind(viewModel)
    }
    
    func configurePairAccountView(with viewModel: AccountTypeViewModel) {
        pairAccountView.bind(viewModel)
    }
}

extension AccountTypeSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 32.0
        let verticalInset: CGFloat = 20.0
    }
}

protocol AccountTypeSelectionViewDelegate: class {
    func accountTypeSelectionView(_ accountTypeSelectionView: AccountTypeSelectionView, didSelect mode: AccountSetupMode)
    func accountTypeSelectionView(_ accountTypeSelectionView: AccountTypeSelectionView, didOpen url: URL)
}
