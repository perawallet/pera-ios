//
//  RewardDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SafariServices

class RewardDetailViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    private let account: Account
    
    private let viewModel = RewardDetailViewModel()
    
    // MARK: Components
    
    private lazy var rewardDetailView = RewardDetailView()
    
    // MARK: Initialization
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        viewModel.configure(rewardDetailView, for: account)
    }
    
    override func linkInteractors() {
        rewardDetailView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(rewardDetailView)
        
        rewardDetailView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: RewardDetailViewDelegate

extension RewardDetailViewController: RewardDetailViewDelegate {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView) {
        guard let algorandRewardsWebsite = URL(string: "https://algorand.foundation/rewards-faq") else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: algorandRewardsWebsite)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func rewardDetailViewDidTapOKButton(_ rewardDetailView: RewardDetailView) {
        dismissScreen()
    }
}
