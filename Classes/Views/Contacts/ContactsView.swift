//
//  ContactsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactsView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let inputViewHeight: CGFloat = 60.0
        let separatorInset: CGFloat = 15.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let placeholderColor = rgba(0.67, 0.67, 0.72, 0.3)
    }
    
    override var endsEditingAfterTouches: Bool {
        return true
    }
    
    // MARK: Components
    
    private(set) lazy var contactNameInputView: SingleLineInputField = {
        let contactNameInputView = SingleLineInputField(displaysExplanationText: false)
        contactNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "contacts-search".localized,
            attributes: [NSAttributedString.Key.foregroundColor: Colors.placeholderColor,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))]
        )
        
        contactNameInputView.inputTextField.textColor = SharedColors.black
        contactNameInputView.inputTextField.tintColor = SharedColors.black
        contactNameInputView.nextButtonMode = .next
        contactNameInputView.inputTextField.autocorrectionType = .no
        return contactNameInputView
    }()
    
    private(set) lazy var contactsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(ContactCell.self, forCellWithReuseIdentifier: ContactCell.reusableIdentifier)
        collectionView.register(ContactSelectionCell.self, forCellWithReuseIdentifier: ContactSelectionCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupContactNameInputViewLayout()
        setupContactsCollectionViewLayout()
    }
    
    private func setupContactNameInputViewLayout() {
        addSubview(contactNameInputView)
        
        contactNameInputView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.inputViewHeight)
        }
    }

    private func setupContactsCollectionViewLayout() {
        addSubview(contactsCollectionView)
        
        contactsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(contactNameInputView.snp.bottom).offset(layout.current.separatorInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contactsCollectionView.backgroundView = contentStateView
    }
}
