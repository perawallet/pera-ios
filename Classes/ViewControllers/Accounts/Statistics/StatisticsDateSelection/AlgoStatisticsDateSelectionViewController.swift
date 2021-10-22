// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AlgoStatisticsDateSelectionViewController.swift

import UIKit
import Macaroon

final class AlgoStatisticsDateSelectionViewController: BaseViewController {
    weak var delegate: AlgoStatisticsDateSelectionViewControllerDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var theme = Theme()
    private lazy var algoStatisticsDateSelectionView = AlgoStatisticsDateSelectionView()

    private var selectedOption: AlgosUSDValueInterval

    init(selectedOption: AlgosUSDValueInterval, configuration: ViewControllerConfiguration) {
        self.selectedOption = selectedOption
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        algoStatisticsDateSelectionView.dateOptionsCollectionView.delegate = self
        algoStatisticsDateSelectionView.dateOptionsCollectionView.dataSource = self
    }

    override func prepareLayout() {
        addAlgoStatisticsDateSelectionView()
    }
}

extension AlgoStatisticsDateSelectionViewController {
    private func addAlgoStatisticsDateSelectionView() {
        view.addSubview(algoStatisticsDateSelectionView)
        algoStatisticsDateSelectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AlgoStatisticsDateSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AlgosUSDValueInterval.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlgoStatisticsDateOptionCell = collectionView.dequeueReusableCell(for: indexPath)
        let selectedOption = AlgosUSDValueInterval.allCases[indexPath.item]
        cell.bindData(
            AlgoStatisticsDateOptionViewModel(
                selectedOption,
                isSelected: self.selectedOption == selectedOption)
        )
        return cell
    }
}

extension AlgoStatisticsDateSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedOption = AlgosUSDValueInterval.allCases[indexPath.item]
        delegate?.algoStatisticsDateSelectionViewController(self, didSelect: selectedOption)
        dismissScreen()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

protocol AlgoStatisticsDateSelectionViewControllerDelegate: AnyObject {
    func algoStatisticsDateSelectionViewController(
        _ algoStatisticsDateSelectionViewController: AlgoStatisticsDateSelectionViewController,
        didSelect selectedOption: AlgosUSDValueInterval
    )
}
