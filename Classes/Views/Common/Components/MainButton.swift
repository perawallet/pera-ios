//
//  MainButton.swift

import UIKit

class MainButton: UIButton {
    private let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configureButton()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainButton {
    private func configureButton() {
        titleLabel?.textAlignment = .center
        setTitleColor(Colors.ButtonText.primary, for: .normal)
        setTitle(title, for: .normal)
        setBackgroundImage(img("bg-main-button"), for: .normal)
        titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
    }
}
