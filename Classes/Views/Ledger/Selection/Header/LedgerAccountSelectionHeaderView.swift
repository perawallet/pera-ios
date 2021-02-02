//
//  LedgerAccountSelectionHeaderView.swift

import UIKit

class LedgerAccountSelectionHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("ledger-account-selection-detail".localized)
    }()
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
    }
}

extension LedgerAccountSelectionHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.detailTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension LedgerAccountSelectionHeaderView {
    func bind(_ viewModel: LedgerAccountSelectionHeaderSupplementaryViewModel) {
        titleLabel.text = viewModel.accountCount
    }
    
    static func calculatePreferredSize(with layout: Layout<LayoutConstants>) -> CGSize {
        let width = UIScreen.main.bounds.width
        let constantHeight = layout.current.titleTopInset + layout.current.detailTopInset
        let detailLabelHeight = "ledger-account-selection-detail".localized.height(
            withConstrained: width - layout.current.horizontalInset * 2,
            font: UIFont.font(withWeight: .regular(size: 14.0))
        )
        let titleLabelHeight: CGFloat = 24.0
        let height: CGFloat = constantHeight + detailLabelHeight + titleLabelHeight
        return CGSize(width: width, height: height)
    }
}

extension LedgerAccountSelectionHeaderView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
        let titleTopInset: CGFloat = 16.0
        let detailTopInset: CGFloat = 8.0
    }
}
