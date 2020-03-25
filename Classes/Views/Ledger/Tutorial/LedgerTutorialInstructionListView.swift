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
        setShadow(on: view)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var installAppInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-ledger-install"))
        view.setTitle("ledger-tutorial-install-app".localized)
        setShadow(on: view)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var openAppInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-algorand-ledger-tutorial"))
        view.setTitle("ledger-tutorial-open-app".localized)
        setShadow(on: view)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var turnOnBluetoohInstructionView: LedgerTutorialInstructionView = {
        let view = LedgerTutorialInstructionView()
        view.setIcon(img("icon-bluetooth-purple"))
        view.setTitle("ledger-tutorial-bluetooth".localized)
        setShadow(on: view)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    weak var delegate: LedgerTutorialInstructionListViewDelegate?
        
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
    
    override func linkInteractors() {
        super.linkInteractors()
        
        let ledgerBluetoothTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                         action: #selector(didTapLedgerBluetoothConnection))
        let installAppTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                    action: #selector(didTapInstallApp))
        let openAppTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(didTapOpenApp))
        let bluetoothTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                   action: #selector(didTapBluetoothConnection))
        
        openLedgerInstructionView.addGestureRecognizer(ledgerBluetoothTapGestureRecognizer)
        installAppInstructionView.addGestureRecognizer(installAppTapGestureRecognizer)
        openAppInstructionView.addGestureRecognizer(openAppTapGestureRecognizer)
        turnOnBluetoohInstructionView.addGestureRecognizer(bluetoothTapGestureRecognizer)
    }
}

extension LedgerTutorialInstructionListView {
    private func setupOpenLedgerInstructionViewLayout() {
        addSubview(openLedgerInstructionView)
        
        openLedgerInstructionView.layer.cornerRadius = 10
        
        openLedgerInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
    }

    private func setupInstallAppInstructionViewLayout() {
        addSubview(installAppInstructionView)
        
        installAppInstructionView.layer.cornerRadius = 10
        
        installAppInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(openLedgerInstructionView.snp.bottom).offset(6)
            make.height.equalTo(openLedgerInstructionView)
        }
    }

    private func setupOpenAppInstructionViewLayout() {
        addSubview(openAppInstructionView)
        
        openAppInstructionView.layer.cornerRadius = 10
        
        openAppInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(installAppInstructionView.snp.bottom).offset(6)
            make.height.equalTo(openLedgerInstructionView)
        }
    }

    private func setupTurnOnBluetoohInstructionViewLayout() {
        addSubview(turnOnBluetoohInstructionView)
        
        turnOnBluetoohInstructionView.layer.cornerRadius = 10
        
        turnOnBluetoohInstructionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(openAppInstructionView.snp.bottom).offset(6)
            make.height.equalTo(openLedgerInstructionView)
            make.bottom.equalToSuperview()
        }
    }
}

extension LedgerTutorialInstructionListView {
    @objc
    private func didTapLedgerBluetoothConnection() {
        delegate?.ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(self)
    }
    
    @objc
    private func didTapInstallApp() {
        delegate?.ledgerTutorialInstructionListViewDidTapInstallApp(self)
    }
    
    @objc
    private func didTapOpenApp() {
        delegate?.ledgerTutorialInstructionListViewDidTapOpenApp(self)
    }
    
    @objc
    private func didTapBluetoothConnection() {
        delegate?.ledgerTutorialInstructionListViewDidTapBluetoothConnection(self)
    }
}

extension LedgerTutorialInstructionListView {
    private func setShadow(on view: UIView) {
        view.layer.shadowColor = Colors.shadowColor.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowRadius = 4.0
    }
}

extension LedgerTutorialInstructionListView {
    private enum Colors {
        static let shadowColor = rgb(0.91, 0.91, 0.95)
    }
}

protocol LedgerTutorialInstructionListViewDelegate: class {
    func ledgerTutorialInstructionListViewDidTapLedgerBluetoothConnection(_ view: LedgerTutorialInstructionListView)
    func ledgerTutorialInstructionListViewDidTapInstallApp(_ view: LedgerTutorialInstructionListView)
    func ledgerTutorialInstructionListViewDidTapOpenApp(_ view: LedgerTutorialInstructionListView)
    func ledgerTutorialInstructionListViewDidTapBluetoothConnection(_ view: LedgerTutorialInstructionListView)
}
