//
//  EditAccountView.swift

import UIKit

class EditAccountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var nameTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withText("account-name-setup-explanation".localized)
    }()
    
    private(set) lazy var accountNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = Colors.Text.primary
        textField.tintColor = Colors.Text.primary
        textField.font = UIFont.font(withWeight: .medium(size: 18.0))
        return textField
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Main.primary600
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupNameTitleLabelLayout()
        setupAccountNameInputViewLayout()
        setupSeparatorViewLayout()
    }
}

extension EditAccountView {
    private func setupNameTitleLabelLayout() {
        addSubview(nameTitleLabel)
        
        nameTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.nameTitleTopInset)
        }
    }
    
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameTextField)
        
        accountNameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(layout.current.fieldTopInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(accountNameTextField.snp.bottom).offset(layout.current.separatorInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension EditAccountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 16.0
        let nameTitleTopInset: CGFloat = 20.0
        let fieldTopInset: CGFloat = 7.0
        let separatorHeight: CGFloat = 2.0
        let separatorInset: CGFloat = 3.0
        let bottomInset: CGFloat = 24.0
    }
}
