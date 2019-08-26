//
//  ContactsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactsViewControllerDelegate: class {
    
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact)
}

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
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private var contacts = [Contact]()
    private var searchResults = [Contact]()
    
    private let viewModel = ContactsViewModel()
    
    weak var delegate: ContactsViewControllerDelegate?
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) {
            let controller = self.open(.addContact(mode: .new), by: .push) as? AddContactViewController
            
            controller?.delegate = self
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: Notification.Name.ContactAddition,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactDeleted(notification:)),
            name: Notification.Name.ContactDeletion,
            object: nil
        )
    }
    
    override func linkInteractors() {
        contactsView.contactNameInputView.delegate = self
        contactsView.contactsCollectionView.delegate = self
        contactsView.contactsCollectionView.dataSource = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-title".localized
        contactsView.contactsCollectionView.refreshControl = refreshControl
        
        fetchContacts()
    }
    
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts.append(contentsOf: results)
                self.searchResults = self.contacts
                
                if self.searchResults.isEmpty {
                    self.contactsView.contactsCollectionView.contentState = .empty(self.emptyStateView)
                } else {
                    self.contactsView.contactsCollectionView.contentState = .none
                }
                
                self.contactsView.contactsCollectionView.reloadData()
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
    
    @objc
    private func didRefreshList() {
        contacts.removeAll()
        fetchContacts()
    }
    
    @objc
    fileprivate func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
            let contact = userInfo["contact"] else {
                return
        }
        
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .none
        }
        
        contacts.append(contact)
        
        if let name = contact.name,
            let currentQuery = contactsView.contactNameInputView.inputTextField.text,
            !currentQuery.isEmpty {
            
            if name.lowercased().contains(currentQuery.lowercased()) {
                searchResults.append(contact)
            }
            
            contactsView.contactsCollectionView.reloadData()
            return
        }
        
        searchResults.append(contact)
        
        contactsView.contactsCollectionView.reloadData()
    }
    
    @objc
    fileprivate func didContactDeleted(notification: Notification) {
        contacts.removeAll()
        fetchContacts()
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
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: ContactCell, at indexPath: IndexPath) {
        cell.delegate = self
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.row]
            
            viewModel.configure(cell, with: contact)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 86.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.row]
            
            guard let delegate = delegate else {
                let controller = open(.contactDetail(contact: contact), by: .push) as? ContactInfoViewController
                controller?.delegate = self
                
                return
            }
            
            popScreen()
            delegate.contactsViewController(self, didSelect: contact)
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
        
        let predicate = NSPredicate(format: "name contains[c] %@", query)
        
        Contact.fetchAll(entity: Contact.entityName, with: predicate) { response in
            switch response {
            case let .results(objects):
                if let contactResults = objects as? [Contact] {
                    self.searchResults = contactResults
                }
            default:
                break
            }
        }
        
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
    
    func contactCellDidTapSendButton(_ cell: ContactCell) {
        view.endEditing(true)
        
        guard let indexPath = contactsView.contactsCollectionView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.row]
            
            guard let currentAccount = session?.currentAccount else {
                return
            }
            
            open(.sendAlgos(account: currentAccount, receiver: .contact(contact)), by: .push)
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
            
            if name.lowercased().contains(currentQuery.lowercased()) {
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
