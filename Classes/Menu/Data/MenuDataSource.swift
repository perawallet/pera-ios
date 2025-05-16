// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MenuDataSource.swift

import UIKit

final class MenuDataSource: NSObject {
    private(set) lazy var menuOptions: [MenuOption] = [
        .cards(withCardCreated: false), .nfts, .buyAlgo, .receive, .inviteFriends
    ]

    private let sharedDataController: SharedDataController
    private var session: Session?
    
    init(
        sharedDataController: SharedDataController,
        session: Session?
    ) {
        self.sharedDataController = sharedDataController
        super.init()
        self.session = session
    }
}

extension MenuDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let option = menuOptions[safe: indexPath.row] {
            switch option {
            case .cards:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath)

                // Remove previous label if any (avoid duplication)
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }

                let label = UILabel(frame: cell.contentView.bounds)
                label.text = "Cards: implemented later"
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 14)
                
                cell.contentView.addSubview(label)
                cell.backgroundColor = .lightGray
                return cell
            case .nfts, .transfer, .buyAlgo, .receive, .inviteFriends:
                let cell = collectionView.dequeue(MenuListViewCell.self, at: indexPath)
                cell.bindData(option)
                return cell
            }
        }

        fatalError("Index path is out of bounds")
    }
}
