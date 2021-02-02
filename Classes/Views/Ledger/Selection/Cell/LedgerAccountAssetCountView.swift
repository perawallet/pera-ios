//
//  LedgerAccountAssetCountView.swift

import UIKit

class LedgerAccountAssetCountView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private lazy var assetCountLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupAssetCountLabelLayout()
    }
}

extension LedgerAccountAssetCountView {
    private func setupAssetCountLabelLayout() {
        addSubview(assetCountLabel)
        
        assetCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension LedgerAccountAssetCountView {
    func bind(_ viewModel: LedgerAccountAssetCountViewModel) {
        assetCountLabel.text = viewModel.assetCount
    }
}

extension LedgerAccountAssetCountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
    }
}
