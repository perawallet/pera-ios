//
//  LedgerTutorialNumberView.swift

import UIKit

class LedgerTutorialNumberView: BaseView {
    
    private lazy var numberLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(Colors.Text.tertiary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.LedgerTutorialNumber.background
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupNumberLabelLayout()
    }
}

extension LedgerTutorialNumberView {
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }
}

extension LedgerTutorialNumberView {
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func setNumber(_ number: Int) {
        numberLabel.text = "\(number)"
    }
}

extension Colors {
    fileprivate enum LedgerTutorialNumber {
        static let background = color("ledgerTutorialNumberBackground")
    }
}
