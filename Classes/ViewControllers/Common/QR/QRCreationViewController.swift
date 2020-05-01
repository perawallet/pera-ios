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
    
    private lazy var qrCreationView = QRCreationView(address: address, mode: mode, mnemonic: mnemonic)
    
    private let address: String
    private let mnemonic: String?
    var mode: QRMode = .mnemonic
    
    init(configuration: ViewControllerConfiguration, address: String, mnemonic: String? = nil) {
        self.address = address
        self.mnemonic = mnemonic
        super.init(configuration: configuration)
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
        
        if mode == .address {
            qrCreationView.setAddress(address)
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
    func qrCreationViewDidTapShareButton(_ qrCreationView: QRCreationView) {
        guard let qrImage = qrCreationView.getQRImage() else {
            return
        }
        
        let sharedItem = [qrImage]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func qrCreationView(_ qrCreationView: QRCreationView, didSelect text: String) {
        UIPasteboard.general.string = text
    }
}

enum QRMode {
    case address
    case mnemonic
    case algosRequest
    case assetRequest
}
