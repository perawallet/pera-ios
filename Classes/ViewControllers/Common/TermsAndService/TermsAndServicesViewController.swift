//
//  TermsAndServicesViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 27.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SafariServices

class TermsAndServicesViewController: BaseViewController {
    private lazy var termsAndServicesView: TermsAndServicesView = {
        TermsAndServicesView()
    }()
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        view.addSubview(termsAndServicesView)
        termsAndServicesView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        termsAndServicesView.delegate = self
    }
}

// MARK: TermsAndServicesViewDelegate
extension TermsAndServicesViewController: TermsAndServicesViewDelegate {
    func termsAndServicesViewDidCheck(_ view: TermsAndServicesView) {
        termsAndServicesView.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true) {
                self.session?.acceptTermsAndServices()
            }
        }
    }
    
    func termsAndServicesView(_ view: TermsAndServicesView, didTap url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
