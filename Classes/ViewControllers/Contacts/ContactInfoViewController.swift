//
//  ContactInfoViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactInfoViewControllerDelegate: class {
    
    func contactInfoViewController(_ contactInfoViewController: ContactInfoViewController, didUpdate contact: Contact)
}

class ContactInfoViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var contactInfoView: ContactInfoView = {
        let view = ContactInfoView()
        return view
    }()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-blue"),
        bottomImage: img("icon-transaction-empty-orange")
    )
    
    private let viewModel = ContactInfoViewModel()
    
    private let contact: Contact
    
    weak var delegate: ContactInfoViewControllerDelegate?
    
    // MARK: Initialization
    
    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .share) {
            self.shareContact()
        }
        
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-info".localized
        
        viewModel.configure(contactInfoView.userInformationView, with: contact)
    }
    
    override func linkInteractors() {
        contactInfoView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(contactInfoView)
        
        contactInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func shareContact() {
        guard let address = contact.address else {
            return
        }
        
        let sharedItem = [address]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: ContactInfoViewDelegate

extension ContactInfoViewController: ContactInfoViewDelegate {
    
    func contactInfoViewDidTapQRCodeButton(_ contactInfoView: ContactInfoView) {
        tabBarController?.open(.contactQRDisplay(contact: contact), by: .presentWithoutNavigationController)
    }
    
    func contactInfoViewDidTapSendButton(_ contactInfoView: ContactInfoView) {
        guard let currentAccount = session?.currentAccount else {
            return
        }
        
        open(.sendAlgos(account: currentAccount, receiver: .contact(contact)), by: .push)
    }
    
    func contactInfoViewDidEditContactButton(_ contactInfoView: ContactInfoView) {
        let controller = open(.addContact(mode: .edit(contact: contact)), by: .push) as? AddContactViewController
        
        controller?.delegate = self
    }
    
    func contactInfoViewDidDeleteContactButton(_ contactInfoView: ContactInfoView) {
        displayRemoveAccountAlert()
    }
    
    private func displayRemoveAccountAlert() {
        let configurator = AlertViewConfigurator(
            title: "contacts-delete-contact-alert-title".localized,
            image: img("icon-delete-contact"),
            explanation: "contacts-delete-contact-alert-explanation".localized,
            actionTitle: "title-yes".localized) {
                self.contact.remove(entity: Contact.entityName)
                
                NotificationCenter.default.post(
                    name: Notification.Name.ContactDeletion,
                    object: self,
                    userInfo: ["contact": self.contact]
                )
                
                self.popScreen()
                return
        }
        
        let viewController = AlertViewController(mode: .destructive, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        if let alertView = viewController.alertView as? DestructiveAlertView {
            alertView.cancelButton.setTitleColor(SharedColors.purple, for: .normal)
            alertView.cancelButton.setBackgroundImage(img("bg-purple-cancel"), for: .normal)
            alertView.actionButton.setTitleColor(SharedColors.orange, for: .normal)
            alertView.actionButton.setBackgroundImage(img("bg-orange-action"), for: .normal)
        }
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}

// MARK: AddContactViewControllerDelegate

extension ContactInfoViewController: AddContactViewControllerDelegate {
    
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact) {
        viewModel.configure(contactInfoView.userInformationView, with: contact)
        
        delegate?.contactInfoViewController(self, didUpdate: contact)
    }
}
