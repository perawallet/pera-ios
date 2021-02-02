//
//  UIViewController+Flow.swift

import UIKit

extension UIViewController {
    
    @discardableResult
    func open<T: UIViewController>(
        _ screen: Screen,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        
        let viewController = UIApplication.shared.route(to: screen, from: self, by: style, animated: animated, then: completion)
        
        return viewController as? T
    }

    func closeScreen(by style: Screen.Transition.Close, animated: Bool = true, onCompletion completion: EmptyHandler? = nil) {
        switch style {
        case .pop:
            navigationController?.popViewController(animated: animated)
        case .dismiss:
            presentingViewController?.dismiss(animated: animated, completion: {
                completion?()
            })
        }
    }
    
    func dismissScreen() {
        closeScreen(by: .dismiss)
    }
    
    func popScreen() {
        closeScreen(by: .pop)
    }
}
