//
//  AddNewAccountViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.04.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AddNewAccountViewController: BaseViewController {
    
    private lazy var addNewAccountView = AddNewAccountView()
        
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = color("secondaryBackground")
    }
        
    override func prepareLayout() {
        super.prepareLayout()
        setupAddNewAccountViewLayout()
    }
        
    override func linkInteractors() {
        addNewAccountView.delegate = self
    }
}

extension AddNewAccountViewController {
    private func setupAddNewAccountViewLayout() {
        view.addSubview(addNewAccountView)
        
        addNewAccountView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AddNewAccountViewController: AddNewAccountViewDelegate {
    func addNewAccountViewDidTapCreateAccountButton(_ addNewAccountView: AddNewAccountView) {
        open(.passphraseView(address: "temp"), by: .push)
    }
        
    func addNewAccountViewDidTapPairLedgerAccountButton(_ addNewAccountView: AddNewAccountView) {
        open(.ledgerTutorial(mode: .new), by: .push)
    }
        
    func addNewAccountViewDidTapRecoverButton(_ addNewAccountView: AddNewAccountView) {
        open(.accountRecover(mode: .new), by: .push)
    }
}
