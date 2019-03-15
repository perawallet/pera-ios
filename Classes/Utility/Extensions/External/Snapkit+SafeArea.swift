//
//  Snapkit+SafeArea.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import SnapKit

extension ConstraintMakerRelatable {
    
    @discardableResult
    func safeEqualToTop(of viewController: UIViewController) -> ConstraintMakerEditable {
        return equalTo(viewController.view.safeAreaLayoutGuide.snp.top)
    }
    
    @discardableResult
    func safeEqualToBottom(of viewController: UIViewController) -> ConstraintMakerEditable {
        return equalTo(viewController.view.safeAreaLayoutGuide.snp.bottom)
    }
}
