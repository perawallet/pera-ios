//
//  Snapkit+SafeArea.swift

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
