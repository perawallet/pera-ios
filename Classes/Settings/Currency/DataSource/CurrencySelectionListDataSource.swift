import Foundation
import UIKit

final class CurrencySelectionListDataSource: UICollectionViewDiffableDataSource<CurrencySelectionSection, CurrencySelectionItem> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let .currency(item):
                let cell =  collectionView.dequeue(
                    SingleSelectionCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case let .noContent(item):
                let cell = collectionView.dequeue(
                    NoContentCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .error:
                let cell = collectionView.dequeue(
                    NoContentWithActionCell.self,
                    at: indexPath
                )
                cell.bindData(ListErrorViewModel())
                return cell
            }
        }
        
        supplementaryViewProvider = {
            collectionView, kind, indexPath in
            
            guard let section = CurrencySelectionSection(rawValue: indexPath.section),
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            let header = collectionView.dequeueHeader(
                SingleGrayTitleHeaderSuplementaryView.self,
                at: indexPath
            )
            
            switch section {
            case .currencies:
                header.bindData(
                    SingleGrayTitleHeaderViewModel("settings-currency-header-title".localized)
                )
                return header
            default:
                return nil
            }
        }
        
        collectionView.register(SingleSelectionCell.self)
        collectionView.register(NoContentCell.self)
        collectionView.register(NoContentWithActionCell.self)
        collectionView.register(header: SingleGrayTitleHeaderSuplementaryView.self)
    }
}
