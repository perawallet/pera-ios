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
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private let account: Account
    
    private let viewModel = RewardDetailViewModel()
    
    private lazy var rewardDetailView = RewardDetailView()
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        viewModel.configure(rewardDetailView, for: account)
    }
    
    override func linkInteractors() {
        rewardDetailView.delegate = self
    }
    
    override func prepareLayout() {
        setupRewardDetailViewLayout()
    }
}

extension RewardDetailViewController {
    private func setupRewardDetailViewLayout() {
        view.addSubview(rewardDetailView)
        
        rewardDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RewardDetailViewController: RewardDetailViewDelegate {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView) {
        guard let algorandRewardsWebsite = URL(string: "https://algorand.foundation/faq#participation-rewards") else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: algorandRewardsWebsite)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    func rewardDetailViewDidTapOKButton(_ rewardDetailView: RewardDetailView) {
        dismissScreen()
    }
}
