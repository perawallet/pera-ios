//
//  TransactionReceiverView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum AlgosReceiverState {
    case initial
    case contact
    case address
}

protocol TransactionReceiverViewDelegate: class {
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapQRButton(_ transactionReceiverView: TransactionReceiverView)
}

class TransactionReceiverView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let bottomInset: CGFloat = 20.0
        let buttonMinimumInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: TransactionReceiverViewDelegate?
    
    var state: AlgosReceiverState = .initial {
        didSet {
            
        }
    }
    
    private(set) lazy var receiverContactView = ContactContextView()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))
        label.text = "send-algos-to".localized
        label.textColor = SharedColors.softGray
        return label
    }()
    
    private lazy var receiverContainerView = UIView()
    
    private(set) lazy var passphraseInputView: MultiLineInputField = {
        let passphraseInputView = MultiLineInputField(displaysExplanationText: false, separatorStyle: .none)
        passphraseInputView.placeholderLabel.text = "contacts-input-address-placeholder".localized
        passphraseInputView.nextButtonMode = .submit
        passphraseInputView.inputTextView.autocorrectionType = .no
        passphraseInputView.inputTextView.autocapitalizationType = .none
        return passphraseInputView
    }()
    
    private(set) lazy var qrButton: UIButton = {
        let button = UIButton(type: .custom)
        //button.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        return button
    }()
    
    private(set) lazy var contactsButton: UIButton = {
        let button = UIButton(type: .custom)
        //button.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        return button
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(receiverContainerView.snp.bottom).offset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview()
        }
    }

}
