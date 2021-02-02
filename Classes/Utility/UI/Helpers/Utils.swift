//
//  Utils.swift

import UIKit

typealias ModalPresentableViewController = ModalPresentable & UIViewController

typealias AnimatorObjectType = ModalAnimator & NSObject
typealias ModalPresenterObjectType = ModalPresenter & NSObject

func img(_ named: String) -> UIImage? {
    return img(named, isTemplate: false)
}

func color(_ named: String) -> UIColor {
    return UIColor(named: named) ?? .black
}

func img(_ named: String, isTemplate: Bool) -> UIImage? {
    let image: UIImage?
    
    if isTemplate {
        image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
    } else {
        image = UIImage(named: named)
    }
    
    return image
}

func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return UIColor(red: red, green: green, blue: blue)
}

func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: red, green: green, blue: blue, alpha: min(1.0, max(0.0, alpha)))
}

let verticalScale = UIScreen.main.bounds.height / 812.0 > 1.0 ? 1.0 : UIScreen.main.bounds.height / 812.0
let horizontalScale = UIScreen.main.bounds.width / 375.0 > 1.0 ? 1.0 : UIScreen.main.bounds.width / 375.0 

func runIfDebug(_ closure: () -> Void) {
    #if DEBUG
    closure()
    #endif
}

func runIfRelease(_ closure: () -> Void) {
    #if !DEBUG
    closure()
    #endif
}
