// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   PassphraseWarningScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class PassphraseWarningScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    
    // MARK: - Properties
    
    typealias EventHandler = (Event) -> Void
    
    fileprivate let dataController: PassphraseWarningDataController

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var iconImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var mainButton = Button()
    private lazy var secondaryButton = Button()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.register(WarningCheckCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private let theme: PassphraseWarningScreenTheme
    
    // MARK: - Initialisers

    init(
        theme: PassphraseWarningScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        self.dataController = PassphraseWarningDataController(warningRowsArray: [
            String(localized: "passphrase-warning-row1-title"),
            String(localized: "passphrase-warning-row2-title"),
            String(localized: "passphrase-warning-row3-title"),
            String(localized: "passphrase-warning-row4-title")
        ])
        super.init(configuration: configuration)
    }
    
    // MARK: - Setups
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    private func addUI() {
        addBackground()
        addContext()
    }
    
    private func updateUIAfterSelection(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
        mainButton.isEnabled = dataController.isFinishActionEnabled
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addIcon()
        addTitle()
        addDescription()
        addCollectionView()
        addButtons()
    }
    
    private func addIcon() {
        iconImageView.customizeAppearance(theme.icon)
        contextView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints {
            $0.top == 0
            $0.centerX.equalToSuperview()
        }
    }

    private func addTitle() {
        titleLabel.customizeAppearance(theme.title)
        contextView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top == iconImageView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.centerX.equalToSuperview()
        }
    }
    
    private func addDescription() {
        descriptionLabel.customizeAppearance(theme.description)
        contextView.addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
    
    private func addCollectionView() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top == descriptionLabel.snp.bottom + theme.spacingBetweendDescriptionAndCollectionView
            $0.leading.equalToSuperview().inset(theme.collectionViewHorizontalPadding)
            $0.trailing.equalToSuperview().inset(theme.collectionViewHorizontalPadding)
            $0.height.equalTo(Int(theme.collectionViewRowHeight) * dataController.rows.count)
        }
    }
    
    private func addButtons() {
        mainButton.customize(theme.mainButtonTheme)
        mainButton.bindData(ButtonCommonViewModel(title: String(localized: "title-reveal-passphrase")))
        mainButton.isEnabled = false
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        contextView.addSubview(mainButton)
        
        secondaryButton.customize(theme.secondaryButtonTheme)
        secondaryButton.bindData(ButtonCommonViewModel(title: String(localized: "title-close")))
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        contextView.addSubview(secondaryButton)
        
        mainButton.snp.makeConstraints {
            $0.top == collectionView.snp.bottom + theme.spacingBetweenCollectionViewAndMainButton
            $0.leading.equalToSuperview().inset(theme.buttonsHorizontalInset)
            $0.trailing.equalToSuperview().inset(theme.buttonsHorizontalInset)
            $0.height.equalTo(theme.buttonHeight)
        }
        
        secondaryButton.snp.makeConstraints {
            $0.top == mainButton.snp.bottom + theme.spacingBetweendMainAndSecondaryButtons
            $0.leading.equalToSuperview().inset(theme.buttonsHorizontalInset)
            $0.trailing.equalToSuperview().inset(theme.buttonsHorizontalInset)
            $0.height.equalTo(theme.buttonHeight)
            $0.bottom.equalToSuperview().inset(theme.secondaryButtonBottomPadding)
        }
    }
    
    // MARK: - Action
    
    @objc private func mainButtonTapped() {
        eventHandler?(.reveal)
    }
    
    @objc private func secondaryButtonTapped() {
        eventHandler?(.close)
    }
}

extension PassphraseWarningScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = theme.collectionViewRowHeight
        return CGSize(width: width, height: height)
    }
}

extension PassphraseWarningScreen: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataController.rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(
            WarningCheckCell.self,
            at: indexPath
        )
        
        cell.accessory = dataController.isRowSelected(at: indexPath.row) ? .selected : .unselected
        cell.bindData(dataController.rows[indexPath.row])
        return cell
    }
}

extension PassphraseWarningScreen: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.updateSelectionWithItem(at: indexPath.row)
        updateUIAfterSelection(at: [indexPath])
    }
}

extension PassphraseWarningScreen {
    enum Event {
        case reveal
        case close
    }
}
