//
//  BaseView.swift

import UIKit

class BaseView: UIView {
    
    var endsEditingAfterTouches: Bool {
        return false
    }

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
        backgroundColor = Colors.Background.primary
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }
    
    @available(iOS 12.0, *)
    func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if endsEditingAfterTouches {
            endEditing(true)
        }
        
        return super.hitTest(point, with: event)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                preferredUserInterfaceStyleDidChange(to: traitCollection.userInterfaceStyle)
            }
        }
    }
}
