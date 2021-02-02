//
//  NumpadButton.swift

import UIKit

class NumpadButton: UIButton {
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.size
    }
    
    private(set) var numpadKey: NumpadKey
    
    init(numpadKey: NumpadKey) {
        self.numpadKey = numpadKey
        super.init(frame: .zero)
        
        configureAppearance()
        setNumpadKey()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance() {
        switch numpadKey {
        case .number:
            setBackgroundImage(img("bg-passcode-number"), for: .normal)
            setBackgroundImage(img("bg-passcode-number-selected"), for: .highlighted)
            setTitleColor(Colors.Text.primary, for: .normal)
            titleLabel?.font = UIFont.font(withWeight: .medium(size: 24.0))
            titleLabel?.textAlignment = .center
        default:
            break
        }
    }
    
    private func setNumpadKey() {
        switch numpadKey {
        case .spacing:
            break
        case let .number(value):
            setTitle(value, for: .normal)
        case .delete:
            setImage(img("icon-delete-number"), for: .normal)
        }
    }
}

extension NumpadButton {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let size = CGSize(width: 72.0 * verticalScale, height: 72.0 * verticalScale)
    }
}
