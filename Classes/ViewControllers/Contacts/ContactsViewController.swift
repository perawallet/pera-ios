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
            let controller = self.open(.addContact(mode: .new), by: .push) as? AddContactViewController
            
            controller?.delegate = self
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
        
        fetchContacts()
    }
    
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts.append(contentsOf: results)
                self.searchResults = self.contacts
                
                if self.searchResults.isEmpty {
                    self.contactsView.contactsCollectionView.contentState = .empty(self.emptyStateView)
                }
            default:
                break
            }
        }
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
            
            let controller = open(.contactDetail(contact: contact), by: .push) as? ContactInfoViewController
            
            controller?.delegate = self
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
            
            tabBarController?.open(.contactQRDisplay(contact: contact), by: .presentWithoutNavigationController)
        }
    }
}

extension ContactsViewController: AddContactViewControllerDelegate {
    
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact) {
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .none
        }
        
        contacts.append(contact)
        
        if let name = contact.name,
            let currentQuery = contactsView.contactNameInputView.inputTextField.text,
            !currentQuery.isEmpty {
            
            if name.contains(currentQuery) {
                searchResults.append(contact)
            }
            
            contactsView.contactsCollectionView.reloadData()
            return
        }
        
        searchResults.append(contact)
        
        contactsView.contactsCollectionView.reloadData()
    }
}

extension ContactsViewController: ContactInfoViewControllerDelegate {
    
    func contactInfoViewController(_ contactInfoViewController: ContactInfoViewController, didUpdate contact: Contact) {
        if let updatedContact = contacts.index(of: contact) {
            contacts[updatedContact] = contact
        }
        
        guard let index = searchResults.index(of: contact) else {
            return
        }
        
        searchResults[index] = contact
        
        contactsView.contactsCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
}
