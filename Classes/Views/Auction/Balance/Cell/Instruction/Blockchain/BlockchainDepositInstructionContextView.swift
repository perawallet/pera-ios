//
//  BlockchainDepositInstructionContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BlockchainDepositInstructionContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components

    private(set) lazy var sendInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-send-title".localized
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var receiverInformationView: InstructionInformationView = {
        let view = InstructionInformationView()
        view.titleLabel.text = "balance-to-title".localized
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupSendInformationViewLayout()
        setupSeparatorViewLayout()
        setupReceiverInformationViewLayout()
    }
    
    private func setupSendInformationViewLayout() {
        addSubview(sendInformationView)
        
        sendInformationView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(sendInformationView.snp.bottom)
        }
    }
    
    private func setupReceiverInformationViewLayout() {
        addSubview(receiverInformationView)
        
        receiverInformationView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
