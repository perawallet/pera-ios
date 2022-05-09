// Copyright 2022 Pera Wallet, LDA

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
//  QRCreationViewController.swift

import UIKit

final class QRCreationViewController: BaseScrollViewController {
    private lazy var qrCreationView = QRCreationView(draft: draft)
    private lazy var theme = Theme()
    
    override var name: AnalyticsScreenName? {
        return isTrackable ? .showQR : nil
    }
    
    private let draft: QRCreationDraft
    private let isTrackable: Bool
    
    init(
        draft: QRCreationDraft,
        configuration: ViewControllerConfiguration,
        isTrackable: Bool = false
    ) {
        self.draft = draft
        self.isTrackable = isTrackable
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addBarButtons()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func setListeners() {
        super.setListeners()
        qrCreationView.setListeners()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        qrCreationView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addQRCreationView()
    }
    
    override func bindData() {
        super.bindData()
        
        if draft.isSelectable {
            qrCreationView.bindData(QRAddressLabelViewModel(title: draft.title ?? draft.address.shortAddressDisplay, address: draft.address))
        }
    }
}

extension QRCreationViewController {
    private func addQRCreationView() {
        contentView.addSubview(qrCreationView)
        qrCreationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension QRCreationViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension QRCreationViewController: QRCreationViewDelegate {
    func qrCreationViewDidShare(_ qrCreationView: QRCreationView) {
        guard let qrImage = qrCreationView.getQRImage() else {
            return
        }
        
        let sharedItem = [qrImage]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        activityViewController.completionWithItemsHandler = { [weak self] _, success, _, _ in
            if success {
                guard let self = self else {
                    return
                }
                self.log(ReceiveShareCompleteEvent(address: self.draft.address))
            }
        }
        
        log(ReceiveShareEvent(address: draft.address))
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func qrCreationViewDidCopy(_ qrCreationView: QRCreationView) {
        log(ReceiveCopyEvent(address: draft.address))
        UIPasteboard.general.string = draft.address
        bannerController?.presentInfoBanner("qr-creation-copied".localized)
    }
}

enum QRMode {
    case address
    case mnemonic
    case algosRequest
    case assetRequest
}
