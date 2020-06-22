//
//  ContactInfoViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

class ContactInfoViewController: BaseScrollViewController {
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private lazy var contactInfoView = ContactInfoView()
    
    private let viewModel = ContactInfoViewModel()
    private let contact: Contact
    private var contactAccount: Account?
    private var selectedAsset: AssetDetail?
    
    weak var delegate: ContactInfoViewControllerDelegate?
    
    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let editBarButtonItem = ALGBarButtonItem(kind: .edit) { [unowned self] in
            let controller = self.open(
                .addContact(mode: .edit(contact: self.contact)),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? AddContactViewController
            controller?.delegate = self
        }
        rightBarButtonItems = [editBarButtonItem]
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
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactDeleted(notification:)),
            name: .ContactDeletion,
            object: nil
        )
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
        
        api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { [weak self] response in
            switch response {
            case let .success(account):
                self?.contactAccount = account
                
                if account.isThereAnyDifferentAsset() {
                    if let assets = account.assets {
                        var failedAssetFetchCount = 0
                        for (index, _) in assets {
                            self?.api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(index)")) { assetResponse in
                                switch assetResponse {
                                case let .success(assetDetail):
                                    assetDetail.id = Int64(index)
                                    
                                    if let verifiedAssets = self?.session?.verifiedAssets,
                                        verifiedAssets.contains(where: { verifiedAsset -> Bool in
                                            "\(verifiedAsset.id)" == index
                                        }) {
                                        assetDetail.isVerified = true
                                    }
                                    
                                    account.assetDetails.append(assetDetail)
                                    
                                    if assets.count == account.assetDetails.count + failedAssetFetchCount {
                                        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                                        SVProgressHUD.dismiss()
                                        
                                        guard let strongSelf = self else {
                                            return
                                        }
                                        strongSelf.contactAccount = account
                                        strongSelf.configureViewForContactAssets()
                                    }
                                case .failure:
                                    failedAssetFetchCount += 1
                                }
                            }
                        }
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                        SVProgressHUD.dismiss()
                    }
                } else {
                    SVProgressHUD.showSuccess(withStatus: "title-done".localized)
                    SVProgressHUD.dismiss()
                }
            case .failure:
                self?.contactAccount = nil
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func configureViewForContactAssets() {
        guard let account = contactAccount else {
            return
        }
        
        let collectionViewHeight = CGFloat((account.assetDetails.count + 1) * 72) + CGFloat((account.assetDetails.count + 1) * 8)
        
        contactInfoView.assetsCollectionView.snp.updateConstraints { make in
            make.height.equalTo(collectionViewHeight)
        }
        
        contactInfoView.assetsCollectionView.reloadData()
    }
    
    @objc
    private func didContactDeleted(notification: Notification) {
        closeScreen(by: .pop, animated: false)
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
        return CGSize(width: view.frame.width - 40.0, height: 72.0)
    }
}

extension ContactInfoViewController: ContactAssetCellDelegate {
    func contactAssetCellDidTapSendButton(_ contactAssetCell: ContactAssetCell) {
        guard let itemIndex = contactInfoView.assetsCollectionView.indexPath(for: contactAssetCell),
            let contactAccount = contactAccount else {
            return
        }
        
        let accountListViewController = open(
            .accountList(mode: .contact(assetDetail: itemIndex.item == 0 ? nil : contactAccount.assetDetails[itemIndex.item - 1])),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        if itemIndex.item != 0 {
            selectedAsset = contactAccount.assetDetails[itemIndex.item - 1]
        }
        
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
        guard let address = contact.address else {
            return
        }

        let draft = QRCreationDraft(address: address, mode: .address)
        open(.qrGenerator(title: contact.name, draft: draft), by: .present)
    }
    
    func contactInfoViewDidTapShareButton(_ contactInfoView: ContactInfoView) {
        shareContact()
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
        if let assetDetail = selectedAsset {
            selectedAsset = nil
            open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .contact(contact),
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false
                ),
                by: .push
            )
        } else {
            open(.sendAlgosTransactionPreview(account: account, receiver: .contact(contact), isSenderEditable: false), by: .push)
        }
    }
}

protocol ContactInfoViewControllerDelegate: class {
    func contactInfoViewController(_ contactInfoViewController: ContactInfoViewController, didUpdate contact: Contact)
}
