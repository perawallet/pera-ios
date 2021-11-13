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
//  ContactDetailViewController.swift

import UIKit

final class ContactDetailViewController: BaseScrollViewController {
    weak var delegate: ContactDetailViewControllerDelegate?
    
    override var name: AnalyticsScreenName? {
        return .contactDetail
    }

    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(theme.modalSize))
    )

    private lazy var theme = Theme()
    private lazy var contactDetailView = ContactDetailView()
    
    private let contact: Contact
    private var contactAccount: Account?
    private var selectedAsset: AssetDetail?
    private var assetPreviews: [AssetPreviewModel] = []

    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContactAccount()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contactDetailView.contactInformationView.bindData(ContactInformationViewModel(contact))
    }
    
    override func linkInteractors() {
        contactDetailView.assetsCollectionView.delegate = self
        contactDetailView.assetsCollectionView.dataSource = self
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactDeleted(notification:)),
            name: .ContactDeletion,
            object: nil
        )
        contactDetailView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        contentView.addSubview(contactDetailView)
        contactDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ContactDetailViewController {
    private func addBarButtons() {
        let editBarButtonItem = ALGBarButtonItem(kind: .edit) { [unowned self] in
            let controller = self.open(
                .editContact(contact: self.contact),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? EditContactViewController
            controller?.delegate = self
        }
        let shareBarButtonItem = ALGBarButtonItem(kind: .share) { [unowned self] in
            self.shareContact()
        }
        rightBarButtonItems = [editBarButtonItem, shareBarButtonItem]
    }
}

extension ContactDetailViewController {
    private func fetchContactAccount() {
        guard let address = contact.address else {
            return
        }
        
        loadingController?.startLoadingWithMessage("title-loading".localized)
        
        api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { [weak self] response in
            switch response {
            case let .success(accountWrapper):
                accountWrapper.account.assets = accountWrapper.account.nonDeletedAssets()
                let account = accountWrapper.account
                self?.contactAccount = account
                let assetPreviewModel = AssetPreviewModelAdapter.adapt(account)
                self?.assetPreviews.append(assetPreviewModel)
                
                if account.isThereAnyDifferentAsset {
                    if let assets = account.assets {
                        var failedAssetFetchCount = 0
                        for asset in assets {
                            self?.api?.getAssetDetails(with: AssetFetchDraft(assetId: "\(asset.id)")) { assetResponse in
                                switch assetResponse {
                                case let .success(assetDetailResponse):
                                    let assetDetail = assetDetailResponse.assetDetail
                                    if let verifiedAssets = self?.session?.verifiedAssets,
                                        verifiedAssets.contains(where: { verifiedAsset -> Bool in
                                            verifiedAsset.id == asset.id
                                        }) {
                                        assetDetail.isVerified = true
                                    }
                                    
                                    account.assetDetails.append(assetDetail)
                                    let assetPreviewModel = AssetPreviewModelAdapter.adapt((assetDetail: assetDetail, asset: asset))
                                    self?.assetPreviews.append(assetPreviewModel)

                                    if assets.count == account.assetDetails.count + failedAssetFetchCount {
                                        self?.loadingController?.stopLoading()
                                        
                                        guard let strongSelf = self else {
                                            return
                                        }
                                        strongSelf.contactAccount = account
                                        strongSelf.contactDetailView.assetsCollectionView.reloadData()
                                    }
                                case .failure:
                                    failedAssetFetchCount += 1
                                }
                            }
                        }
                    } else {
                        self?.loadingController?.stopLoading()
                    }
                } else {
                    self?.loadingController?.stopLoading()
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    self?.contactAccount = Account(address: address, type: .standard)
                    self?.loadingController?.stopLoading()

                    guard let account = self?.contactAccount else { return }
                    let assetPreviewModel = AssetPreviewModelAdapter.adapt(account)
                    self?.assetPreviews.append(assetPreviewModel)
                } else {
                    self?.contactAccount = nil
                    self?.loadingController?.stopLoading()
                }
            }
        }
    }
    
    @objc
    private func didContactDeleted(notification: Notification) {
        closeScreen(by: .pop, animated: false)
    }
}

extension ContactDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetPreviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetPreviewActionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.customize(theme.assetPreviewActionViewTheme)
        cell.bindData(AssetPreviewViewModel(assetPreviews[indexPath.row]))
        cell.delegate = self
        return cell
    }
}

extension ContactDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

extension ContactDetailViewController: AssetPreviewActionCellDelegate {
    func assetPreviewSendCellDidTapSendButton(_ assetPreviewSendCell: AssetPreviewActionCell) {
        guard let itemIndex = contactDetailView.assetsCollectionView.indexPath(for: assetPreviewSendCell),
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

extension ContactDetailViewController {
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

extension ContactDetailViewController: ContactDetailViewDelegate {
    func contactDetailViewDidTapQRButton(_ view: ContactDetailView) {
        guard let address = contact.address else {
            return
        }

        let draft = QRCreationDraft(address: address, mode: .address)
        open(.qrGenerator(title: contact.name, draft: draft, isTrackable: true), by: .present)
    }
}

extension ContactDetailViewController: AddContactViewControllerDelegate {
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact) {
        contactDetailView.contactInformationView.bindData(ContactInformationViewModel(contact))
        delegate?.contactDetailViewController(self, didUpdate: contact)
    }
}

extension ContactDetailViewController: EditContactViewControllerDelegate {
    func editContactViewController(_ editContactViewController: EditContactViewController, didSave contact: Contact) {
        contactDetailView.contactInformationView.bindData(ContactInformationViewModel(contact))
        delegate?.contactDetailViewController(self, didUpdate: contact)
    }
}

extension ContactDetailViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        viewController.dismissScreen()
        
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

    func accountListViewControllerDidCancelScreen(_ viewController: AccountListViewController) {
        viewController.dismissScreen()
    }
}

protocol ContactDetailViewControllerDelegate: AnyObject {
    func contactDetailViewController(_ contactDetailViewController: ContactDetailViewController, didUpdate contact: Contact)
}
