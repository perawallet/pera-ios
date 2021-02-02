//
//  Checkbox.swift

import UIKit

class Checkbox: BaseControl {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-checkbox"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func reconfigureAppearance(for state: State) {
        switch state {
        case .highlighted, .selected:
            imageView.image = img("icon-checkbox-checked")
        case .normal:
            imageView.image = img("icon-checkbox")
        default:
            return
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        let imageViewGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageView.addGestureRecognizer(imageViewGesture)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addSubview(imageView)
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    @objc
    private func didTap() {
        sendActions(for: .allTouchEvents)
    }
}
