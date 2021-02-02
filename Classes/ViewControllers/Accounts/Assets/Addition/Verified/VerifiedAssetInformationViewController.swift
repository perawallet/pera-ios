//
//  VerifiedAssetInformationViewController.swift

import UIKit

class VerifiedAssetInformationViewController: BaseViewController {
    
    private lazy var verifiedAssetInformationView = VerifiedAssetInformationView()
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        navigationItem.title = "verified-assets-title".localized
    }
    
    override func linkInteractors() {
        verifiedAssetInformationView.delegate = self
    }
    
    override func prepareLayout() {
        setupVerifiedAssetInformationViewLayout()
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
}

extension VerifiedAssetInformationViewController {
    private func setupVerifiedAssetInformationViewLayout() {
        view.addSubview(verifiedAssetInformationView)
        
        verifiedAssetInformationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension VerifiedAssetInformationViewController: VerifiedAssetInformationViewDelegate {
    func verifiedAssetInformationViewDidTapContactText(_ verifiedAssetInformationView: VerifiedAssetInformationView) {
        open(.feedback, by: .push)
    }
}
