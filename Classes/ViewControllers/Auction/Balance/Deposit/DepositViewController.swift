//
//  DepositViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol DepositViewControllerDelegate: class {
    
    func depositViewController(_ depositViewController: DepositViewController, didComplete instruction: DepositInstruction)
}

class DepositViewController: BaseScrollViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private var user: AuctionUser
    
    weak var delegate: DepositViewControllerDelegate?
    
    private let viewModel = DepositViewModel()
    
    var btcDepositInformation: BlockchainInstruction?
    var ethDepositInformation: BlockchainInstruction?
    
    private var selectedDepositType: DepositType?
    private var amount: Double?
    
    private var keyboardController = KeyboardController()
    
    // MARK: Components
    
    private lazy var depositView: DepositView = {
        let view = DepositView()
        return view
    }()
    
    // MARK: Initialization
    
    init(user: AuctionUser, configuration: ViewControllerConfiguration) {
        self.user = user
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "deposit-title".localized
        
        viewModel.configure(depositView, for: user)
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        fetchBTCDepositInstructions()
        fetchETHDepositInstructions()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        depositView.delegate = self
        keyboardController.dataSource = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    private func fetchBTCDepositInstructions() {
        api?.fetchBlockchainDepositInformation(for: .btc) { response in
            switch response {
            case let .success(receivedInstruction):
                self.btcDepositInformation = receivedInstruction
                
                self.fetchETHDepositInstructions()
            case .failure:
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchETHDepositInstructions() {
        api?.fetchBlockchainDepositInformation(for: .eth) { response in
            SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
            SVProgressHUD.dismiss()
            
            switch response {
            case let .success(receivedInstruction):
                self.ethDepositInformation = receivedInstruction
                
                if let btcDepositInformation = self.btcDepositInformation,
                    let ethDepositInformation = self.ethDepositInformation {
                    self.viewModel.configure(
                        self.depositView,
                        btcDepositInformation: btcDepositInformation,
                        ethDepositInformation: ethDepositInformation
                    )
                }
            case .failure:
                SVProgressHUD.showError(withStatus: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupDepositViewLayout()
    }
    
    private func setupDepositViewLayout() {
        contentView.addSubview(depositView)
        
        depositView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: DepositViewDelegate

extension DepositViewController: DepositViewDelegate {
    
    func depositViewDidTapDepositButton(_ depositView: DepositView) {
        guard let type = selectedDepositType,
            let amount = depositView.depositAmountView.amountTextField.text?.doubleForReadSeparator else {
                return
        }
        
        let depositInstruction = DepositInstruction(type: type, amount: amount)
        session?.authenticatedUser?.addInstruction(depositInstruction)
        
        delegate?.depositViewController(self, didComplete: depositInstruction)
        popScreen()
    }
    
    func depositViewDidTapCancelButton(_ depositView: DepositView) {
        popScreen()
    }
    
    func depositView(_ depositView: DepositView, didSelect depositType: DepositType) {
        selectedDepositType = depositType
    }
}

// MARK: KeyboardControllerDataSource

extension DepositViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return depositView.depositAmountView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}
