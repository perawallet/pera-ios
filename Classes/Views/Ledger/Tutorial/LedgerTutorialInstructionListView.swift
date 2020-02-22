//
//  LedgerTutorialInstructionListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTutorialInstructionListView: BaseView {
    
    private lazy var openLedgerInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-shutdown"))
        view.setTitle("ledger-tutorial-turned-on".localized)
        return view
    }()
    
    private lazy var installAppInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-ledger-install"))
        view.setTitle("ledger-tutorial-install-app".localized)
        return view
    }()
    
    private lazy var openAppInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-ledger-waiting-small"))
        view.setTitle("ledger-tutorial-open-app".localized)
        return view
    }()
    
    private lazy var turnOnBluetoohInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-bluetooth-purple"))
        view.setTitle("ledger-tutorial-bluetooth".localized)
        view.setSeparatorViewVisible(false)
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 10.0
        setShadow()
    }
        
    override func prepareLayout() {
        setupOpenLedgerInstructionViewLayout()
        setupInstallAppInstructionViewLayout()
        setupOpenAppInstructionViewLayout()
        setupTurnOnBluetoohInstructionViewLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
}

extension LedgerTutorialInstructionListView {
    private func setupOpenLedgerInstructionViewLayout() {
        addSubview(openLedgerInstructionView)
        
        openLedgerInstructionView.layer.cornerRadius = 10
        openLedgerInstructionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        openLedgerInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }

    private func setupInstallAppInstructionViewLayout() {
        addSubview(installAppInstructionView)
        
        installAppInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(openLedgerInstructionView.snp.bottom)
        }
    }

    private func setupOpenAppInstructionViewLayout() {
        addSubview(openAppInstructionView)
        
        openAppInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(installAppInstructionView.snp.bottom)
        }
    }

    private func setupTurnOnBluetoohInstructionViewLayout() {
        addSubview(turnOnBluetoohInstructionView)
        
        turnOnBluetoohInstructionView.layer.cornerRadius = 10
        turnOnBluetoohInstructionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        turnOnBluetoohInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(openAppInstructionView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}

extension LedgerTutorialInstructionListView {
    private func setShadow() {
        layer.shadowColor = Colors.shadowColor.cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 4.0
    }
}

extension LedgerTutorialInstructionListView {
    private enum Colors {
        static let shadowColor = rgb(0.91, 0.91, 0.95)
    }
}
