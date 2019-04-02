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
    
    // TODO: Will be replaced with real contacts
    
    private func setupMockData() {
        for index in 0...20 {
            let contact = Contact()
            
            contact.name = "Contact \(index)"
            contact.address = "123123123123"
            
            contacts.append(contact)
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
}

extension ContactsViewController: InputViewDelegate {
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        guard let query = contactsView.contactNameInputView.inputTextField.text,
            !query.isEmpty else {
                searchResults = contacts
                return
        }
        
        let results = contacts.filter { contact -> Bool in
            guard let name = contact.name else {
                return false
            }
            
            return name.contains(query)
        }
        
        searchResults = results
        
        contactsView.contactsCollectionView.reloadData()
    }
}
