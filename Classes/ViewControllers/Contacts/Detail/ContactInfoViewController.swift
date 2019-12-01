//
//  ContactInfoViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ContactInfoViewControllerDelegate: class {
    func contactInfoViewController(_ contactInfoViewController: ContactInfoViewController, didUpdate contact: Contact)
}

class ContactInfoViewController: BaseScrollViewController {
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private lazy var contactInfoView = ContactInfoView()
    
    private lazy var emptyStateView = EmptyStateView(
        title: "tranaction-empty-text".localized,
        topImage: img("icon-transaction-empty-blue"),
        bottomImage: img("icon-transaction-empty-orange")
    )
    
    private let viewModel = ContactInfoViewModel()
    private let contact: Contact
    private var contactAccount: Account?
    
    weak var delegate: ContactInfoViewControllerDelegate?
    
    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureNavigationBarAppearance() {
        let addBarButtonItem = ALGBarButtonItem(kind: .share) {
            self.shareContact()
        }
        rightBarButtonItems = [addBarButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContactAccount()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "contacts-info".localized
        viewModel.configure(contactInfoView.userInformationView, with: contact)
    }
    
    override func linkInteractors() {
        contactInfoView.delegate = self
        contactInfoView.assetsCollectionView.delegate = self
        contactInfoView.assetsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupContactInfoViewLayout()
    }
}

extension ContactInfoViewController {
    private func setupContactInfoViewLayout() {
        contentView.addSubview(contactInfoView)
        
        contactInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ContactInfoViewController {
    private func fetchContactAccount() {
        guard let address = contact.address else {
            return
        }
        
        SVProgressHUD.show()
        
        api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { [unowned self] response in
            switch response {
            case let .success(account):
                if account.isThereAnyDifferentAsset() {
                    if let assets = account.assets {
                        for (index, _) in assets {
                            self.api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(index)")) { assetResponse in
                                switch assetResponse {
                                case let .success(assetDetail):
                                    assetDetail.index = index
                                    account.assetDetails.append(assetDetail)
                                    
                                    if assets.count == account.assetDetails.count {
                                        SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                                        SVProgressHUD.dismiss()
                                        self.contactAccount = account
                                        self.configureViewForContactAssets()
                                    }
                                case .failure:
                                    SVProgressHUD.dismiss()
                                }
                            }
                        }
                    }
                }
            case .failure:
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func configureViewForContactAssets() {
        guard let account = contactAccount else {
            return
        }
        
        let collectionViewHeight = CGFloat((account.assetDetails.count + 1) * 50) + CGFloat((account.assetDetails.count + 1) * 5)
        
        contactInfoView.assetsCollectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionViewHeight)
        }
        
        contactInfoView.assetsCollectionView.reloadData()
    }
}

extension ContactInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let account = contactAccount else {
            return 1
        }
        
        return account.assetDetails.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContactAssetCell.reusableIdentifier,
            for: indexPath) as? ContactAssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        viewModel.configure(cell, at: indexPath, with: contactAccount)
        cell.delegate = self
        return cell
    }
}

extension ContactInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width - 20.0, height: 50.0)
    }
}

extension ContactInfoViewController: ContactAssetCellDelegate {
    func contactAssetCellDidTapSendButton(_ contactAssetCell: ContactAssetCell) {
        guard let itemIndex = contactInfoView.assetsCollectionView.indexPath(for: contactAssetCell),
            let contactAccount = contactAccount else {
            return
        }
        
        let accountListViewController = open(
            .accountList(mode: .amount(assetDetail: itemIndex.item == 0 ? nil : contactAccount.assetDetails[itemIndex.item - 1])),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
    }
}

extension ContactInfoViewController {
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

extension ContactInfoViewController: ContactInfoViewDelegate {
    func contactInfoViewDidTapQRCodeButton(_ contactInfoView: ContactInfoView) {
        tabBarController?.open(.contactQRDisplay(contact: contact), by: .presentWithoutNavigationController)
    }
    
    func contactInfoViewDidEditContactButton(_ contactInfoView: ContactInfoView) {
        let controller = open(.addContact(mode: .edit(contact: contact)), by: .present) as? AddContactViewController
        controller?.delegate = self
    }
    
    func contactInfoViewDidDeleteContactButton(_ contactInfoView: ContactInfoView) {
        displayDeleteContactAlert()
    }
    
    private func displayDeleteContactAlert() {
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
            alertView.cancelButton.setTitleColor(.white, for: .normal)
            alertView.cancelButton.setBackgroundImage(img("bg-black-cancel"), for: .normal)
            alertView.actionButton.setTitleColor(.white, for: .normal)
            alertView.actionButton.setBackgroundImage(img("bg-purple-action"), for: .normal)
        }
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
}

extension ContactInfoViewController: AddContactViewControllerDelegate {
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact) {
        viewModel.configure(contactInfoView.userInformationView, with: contact)
        delegate?.contactInfoViewController(self, didUpdate: contact)
    }
}

extension ContactInfoViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        open(.sendAlgos(account: account, receiver: .contact(contact)), by: .push)
    }
}
