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
//  AssetActionConfirmationViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class AssetActionConfirmationViewController: BaseViewController {
    weak var delegate: AssetActionConfirmationViewControllerDelegate?

    private lazy var theme = Theme()
    private lazy var assetActionConfirmationView = AssetActionConfirmationView()
    
    private var assetAlertDraft: AssetAlertDraft
    
    init(assetAlertDraft: AssetAlertDraft, configuration: ViewControllerConfiguration) {
        self.assetAlertDraft = assetAlertDraft
        super.init(configuration: configuration)
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchAssetDetailIfNeeded()
    }
    
    override func setListeners() {
        assetActionConfirmationView.setListeners()
        assetActionConfirmationView.delegate = self
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func prepareLayout() {
        assetActionConfirmationView.customize(theme.assetActionConfirmationViewTheme)
        view.addSubview(assetActionConfirmationView)
        assetActionConfirmationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        assetActionConfirmationView.bindData(AssetActionConfirmationViewModel(assetAlertDraft))
    }
}

extension AssetActionConfirmationViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

extension AssetActionConfirmationViewController {
    private func fetchAssetDetailIfNeeded() {
        if !assetAlertDraft.isValid() {
            if let assetDetail = session?.assetDetails[assetAlertDraft.assetIndex] {
                handleAssetDetailSetup(with: assetDetail)
            } else {
                loadingController?.startLoadingWithMessage("title-loading".localized)

                api?.getAssetDetails(AssetFetchDraft(assetId: "\(assetAlertDraft.assetIndex)")) { [weak self] response in
                    switch response {
                    case let .success(assetResponse):
                        self?.handleAssetDetailSetup(with: assetResponse.assetDetail)
                    case .failure:
                        self?.loadingController?.stopLoading()
                    }
                }
            }
        }
    }
    
    private func handleAssetDetailSetup(with asset: AssetDetail) {
        self.loadingController?.stopLoading()
        var assetDetail = asset
        setVerifiedIfNeeded(&assetDetail)
        assetAlertDraft.assetDetail = assetDetail
        assetActionConfirmationView.bindData(AssetActionConfirmationViewModel(assetAlertDraft))
    }
    
    private func setVerifiedIfNeeded(_ assetDetail: inout AssetDetail) {
        if let verifiedAssets = session?.verifiedAssets,
           verifiedAssets.contains(where: { verifiedAsset in
               verifiedAsset.id == self.assetAlertDraft.assetIndex
           }) {
            assetDetail.isVerified = true
        }
    }
}

extension AssetActionConfirmationViewController: AssetActionConfirmationViewDelegate {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        if let assetDetail = assetAlertDraft.assetDetail {
            delegate?.assetActionConfirmationViewController(self, didConfirmedActionFor: assetDetail)
        }
        dismissScreen()
    }
    
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView) {
        dismissScreen()
    }

    func assetActionConfirmationViewDidTapCopyIDButton(_ assetActionConfirmationView: AssetActionConfirmationView, assetID: String?) {
        UIPasteboard.general.string = assetID
        bannerController?.presentInfoBanner("asset-id-copied-title".localized)
    }
}

protocol AssetActionConfirmationViewControllerDelegate: AnyObject {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    )
}
