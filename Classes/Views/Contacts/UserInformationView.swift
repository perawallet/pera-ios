//
//  UserInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol UserInformationViewDelegate: class {
    
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView)
}

class UserInformationView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let backgroundViewSize: CGFloat = 108.0
        let imageInset: CGFloat = 30.0
        let nameInputViewInset: CGFloat = 27.0
        let addressInputViewInset: CGFloat = 20.0
        let buttonSize: CGFloat = 36.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let addButtonColor = rgb(0.34, 0.34, 0.43)
    }
    
    // MARK: Components
    
    private lazy var imageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.warmWhite
        view.layer.cornerRadius = layout.current.backgroundViewSize / 2
        return view
    }()
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder-big"))
        imageView.layer.cornerRadius = layout.current.backgroundViewSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private(set) lazy var addButton: UIButton = {
        let button = UIButton(type: .custom).withBackgroundColor(Colors.addButtonColor).withImage(img("icon-add-white"))
        button.layer.cornerRadius = 18.0
        return button
    }()
    
    private(set) lazy var contactNameInputView: SingleLineInputField = {
        let contactNameInputView = SingleLineInputField(separatorStyle: .colored)
        contactNameInputView.explanationLabel.text = "contacts-input-name-explanation".localized
        contactNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "contacts-input-name-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.montserrat, withWeight: .semiBold(size: 16.0))]
        )
        
        contactNameInputView.inputTextField.textColor = SharedColors.black
        contactNameInputView.inputTextField.tintColor = SharedColors.black
        contactNameInputView.inputTextField.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 16.0))
        contactNameInputView.nextButtonMode = .next
        contactNameInputView.inputTextField.autocorrectionType = .no
        contactNameInputView.backgroundColor = .white
        
        contactNameInputView.inputTextField.isEnabled = isEditable
        return contactNameInputView
    }()
    
    private(set) lazy var algorandAddressInputView: MultiLineInputField = {
        let algorandAddressInputView = MultiLineInputField(displaysRightInputAccessoryButton: true)
        algorandAddressInputView.explanationLabel.text = "contacts-input-address-explanation".localized
        algorandAddressInputView.placeholderLabel.text = "contacts-input-address-placeholder".localized
        algorandAddressInputView.nextButtonMode = .submit
        algorandAddressInputView.inputTextView.autocorrectionType = .no
        algorandAddressInputView.inputTextView.autocapitalizationType = .none
        algorandAddressInputView.rightInputAccessoryButton.setImage(img("icon-qr"), for: .normal)
        algorandAddressInputView.inputTextView.textContainer.heightTracksTextView = false
        algorandAddressInputView.inputTextView.isScrollEnabled = true
        algorandAddressInputView.backgroundColor = .white
        
        algorandAddressInputView.inputTextView.isEditable = isEditable
        return algorandAddressInputView
    }()
    
    weak var delegate: UserInformationViewDelegate?
    
    private var isEditable: Bool
    
    init(isEditable: Bool = true) {
        self.isEditable = isEditable
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupImageBackgroundViewLayout()
        setupUserImageViewLayout()
        setupAddButtonLayout()
        setupContactNameInputViewLayout()
        setupAlgorandAddressInputViewLayout()
    }
    
    private func setupImageBackgroundViewLayout() {
        addSubview(imageBackgroundView)
        
        imageBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageInset)
            make.width.height.equalTo(layout.current.backgroundViewSize)
        }
    }
    
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.edges.lessThanOrEqualTo(imageBackgroundView)
            make.width.height.equalTo(layout.current.backgroundViewSize)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(imageBackgroundView)
            make.width.height.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupContactNameInputViewLayout() {
        addSubview(contactNameInputView)
        
        contactNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(layout.current.nameInputViewInset)
        }
    }
    
    private func setupAlgorandAddressInputViewLayout() {
        addSubview(algorandAddressInputView)
        
        algorandAddressInputView.snp.makeConstraints { make in
            make.top.equalTo(contactNameInputView.snp.bottom).offset(layout.current.addressInputViewInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToAddButtonTapped() {
        delegate?.userInformationViewDidTapAddImageButton(self)
    }
}
