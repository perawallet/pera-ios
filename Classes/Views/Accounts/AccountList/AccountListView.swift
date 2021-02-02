//
//  AccountListView.swift

import UIKit

class AccountListView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountListViewDelegate?
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.secondary
        collectionView.contentInset = .zero
        collectionView.register(AccountViewCell.self, forCellWithReuseIdentifier: AccountViewCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAccountCollectionViewLayout()
        setupCancelButtonLayout()
    }
}

extension AccountListView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.accountListViewDidTapCancelButton(self)
    }
}

extension AccountListView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleLabelOffset)
        }
    }
    
    private func setupAccountCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(accountsCollectionView.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(layout.current.accountListBottomInset)
        }
    }
}

extension AccountListView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 28.0
        let titleLabelOffset: CGFloat = 16.0
        let accountListBottomInset: CGFloat = -20.0
    }
}

protocol AccountListViewDelegate: class {
    func accountListViewDidTapCancelButton(_ accountListView: AccountListView)
}
