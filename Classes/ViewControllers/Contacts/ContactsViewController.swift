//
//  ContactsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactsViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var contactsView: ContactsView = {
        let view = ContactsView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "contacts-empty-text".localized,
        topImage: img("icon-contacts-empty"),
        bottomImage: img("icon-contacts-empty")
    )
    
    private var contacts = [Contact]()
    private var searchResults = [Contact]()
    
    private let viewModel = ContactsViewModel()
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
            self.open(.addContact, by: .push)
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func linkInteractors() {
        contactsView.contactNameInputView.delegate = self
        contactsView.contactsCollectionView.delegate = self
        contactsView.contactsCollectionView.dataSource = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-title".localized
        
        setupMockData()
    }
    
    // TODO: Will be replaced with real contacts. Need to handle empty and loading states after fetching contacts.
    
    private func setupMockData() {
        for index in 0...20 {
            let contact = Contact()
            
            contact.name = "Contact \(index)"
            contact.address = "123123123123"
            
            contacts.append(contact)
        }
        
        searchResults = contacts
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(contactsView)
        
        contactsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: UICollectionViewDataSource

extension ContactsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContactCell.reusableIdentifier,
            for: indexPath) as? ContactCell else {
                fatalError("Index path is out of bounds")
        }
        
        cell.delegate = self
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.row]
            
            viewModel.configure(cell, with: contact)
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 90.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.row]
            
            open(.contactDetail(contact), by: .push)
        }
    }
}

// MARK: InputViewDelegate

extension ContactsViewController: InputViewDelegate {
    
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .empty(emptyStateView)
            return
        }
        
        guard let query = contactsView.contactNameInputView.inputTextField.text,
            !query.isEmpty else {
                contactsView.contactsCollectionView.contentState = .none
                searchResults = contacts
                contactsView.contactsCollectionView.reloadData()
                return
        }
        
        let results = contacts.filter { contact -> Bool in
            guard let name = contact.name else {
                return false
            }
            
            return name.contains(query)
        }
        
        searchResults = results
        
        if searchResults.isEmpty {
            contactsView.contactsCollectionView.contentState = .empty(emptyStateView)
        } else {
            contactsView.contactsCollectionView.contentState = .none
        }
        
        contactsView.contactsCollectionView.reloadData()
    }
}

// MARK: ContactCellDelegate

extension ContactsViewController: ContactCellDelegate {
    
    func contactCellDidTapQRDisplayButton(_ cell: ContactCell) {
        view.endEditing(true)
        
        guard let indexPath = contactsView.contactsCollectionView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.row]
            
            tabBarController?.open(.contactQRDisplay(contact), by: .presentWithoutNavigationController)
        }
    }
}
