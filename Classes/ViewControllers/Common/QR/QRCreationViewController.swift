//
//  QRCreationViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class QRCreationViewController: BaseScrollViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var hidesCloseBarButtonItem: Bool {
        return true
    }
    
    private lazy var qrCreationView = QRCreationView(draft: draft)
    
    private let draft: QRCreationDraft
    private let eventFlow: ReceiveEventFlow?
    
    init(draft: QRCreationDraft, configuration: ViewControllerConfiguration, eventFlow: ReceiveEventFlow? = nil) {
        self.draft = draft
        self.eventFlow = eventFlow
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let event = eventFlow {
            ReceiveEvent(flow: event, address: draft.address).logEvent()
        }
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
        
        if draft.isSelectable {
            qrCreationView.setAddress(draft.address)
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        qrCreationView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupQRCreationViewLayout()
    }
}

extension QRCreationViewController {
    private func setupQRCreationViewLayout() {
        contentView.addSubview(qrCreationView)
        
        qrCreationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        
        activityViewController.completionWithItemsHandler = { [weak self] activity, success, items, error in
            if success {
                if let flow = self?.eventFlow,
                   let address = self?.draft.address {
                    ReceiveShareCompleteEvent(flow: flow, address: address).logEvent()
                }
            }
        }
        
        if let event = eventFlow {
            ReceiveShareEvent(flow: event, address: draft.address).logEvent()
        }
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func qrCreationView(_ qrCreationView: QRCreationView, didSelect text: String) {
        if let event = eventFlow {
            ReceiveCopyEvent(flow: event, address: draft.address).logEvent()
        }
        UIPasteboard.general.string = text
    }
}

enum QRMode {
    case address
    case mnemonic
    case algosRequest
    case assetRequest
}
