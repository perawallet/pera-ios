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
//   UICollectionView+Layout.swift

import UIKit

extension UICollectionView {
    // swiftlint:disable force_cast
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reusableIdentifier, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(of kind: SectionType, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind.identifier, withReuseIdentifier: T.reusableIdentifier, for: indexPath) as! T
    }

    enum SectionType {
        case header
        case footer

        var identifier: String {
            switch self {
            case .header:
                return  UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            }
        }
    }

    func registerSupplementaryView(_ type: UICollectionReusableView.Type, of kind: SectionType) {
        register(
            type.self,
            forSupplementaryViewOfKind: kind.identifier,
            withReuseIdentifier: String(describing: type.self)
        )
    }

    func registerCells(_ types: UICollectionViewCell.Type...) {
        types.forEach {
            registerCell($0)
        }
    }

    func registerCell(_ type: UICollectionViewCell.Type) {
         register(type.self, forCellWithReuseIdentifier: String(describing: type.self))
    }
    // swiftlint:enable force_cast
}
