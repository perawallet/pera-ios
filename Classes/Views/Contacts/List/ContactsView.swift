// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  ContactsView.swift

import UIKit
import Macaroon

final class ContactsView: View {
    weak var delegate: ContactsViewDelegate?

    private lazy var contactsHeaderView = MainHeaderView()
    private(set) lazy var contactNameInputView = SingleLineInputField(displaysExplanationText: false)
    
    private(set) lazy var contactsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.tertiary
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.registerCells(ContactCell.self, ContactSelectionCell.self)
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        linkInteractors()
    }
    
    func linkInteractors() {
        contactsHeaderView.delegate = self
    }

    func customize(_ theme: ContactsViewTheme) {
        addContactsHeaderView()
        addContactNameInputView(theme)
        addContactsCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        endEditing(true)
        return super.hitTest(point, with: event)
    }
}

extension ContactsView {
    private func addContactsHeaderView() {
        contactsHeaderView.backgroundColor = AppColors.Shared.System.background.color
        contactsHeaderView.setTitle("contacts-title".localized)
        contactsHeaderView.setQRButtonHidden(true)
        contactsHeaderView.setTestNetLabelHidden(true)

        addSubview(contactsHeaderView)
        contactsHeaderView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func addContactNameInputView(_ theme: ContactsViewTheme) {
        contactNameInputView.placeholderText = "contacts-search".localized
        contactNameInputView.nextButtonMode = .next
        contactNameInputView.inputTextField.autocorrectionType = .no

        addSubview(contactNameInputView)
        contactNameInputView.snp.makeConstraints {
            $0.top.equalTo(contactsHeaderView.snp.bottom).offset(theme.topInset)
            $0.top.equalToSuperview().inset(theme.topInset).priority(.low)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func addContactsCollectionView(_ theme: ContactsViewTheme) {
        addSubview(contactsCollectionView)
        contactsCollectionView.snp.makeConstraints {
            $0.top.equalTo(contactNameInputView.snp.bottom).offset(theme.listOffset)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        contactsCollectionView.backgroundView = contentStateView
    }
}

extension ContactsView {
    func removeHeader() {
        contactsHeaderView.removeFromSuperview()
    }
}

extension ContactsView: MainHeaderViewDelegate {
    func mainHeaderViewDidTapAddButton(_ mainHeaderView: MainHeaderView) {
        delegate?.contactsViewDidTapAddButton(self)
    }
    
    func mainHeaderViewDidTapQRButton(_ mainHeaderView: MainHeaderView) {}
}

protocol ContactsViewDelegate: AnyObject {
    func contactsViewDidTapAddButton(_ contactsView: ContactsView)
}
