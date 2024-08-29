import UIKit

class TwoRowGridLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()

        guard let collectionView else {
            return
        }

        let availableHeight = collectionView.bounds.height - sectionInset.top - sectionInset.bottom
        let cellHeight = (availableHeight - minimumInteritemSpacing) / 2

        let availableWidth = collectionView.bounds.width
            - collectionView.contentInset.left
            - collectionView.contentInset.right
        let cellWidth = availableWidth * 0.70

        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        itemSize = CGSize(width: cellWidth, height: cellHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        var newAttributes = [UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            // swiftlint:disable:next force_cast
            let newAttribute = attribute.copy() as! UICollectionViewLayoutAttributes

            let item = newAttribute.indexPath.item
            let row = item % 2
            let column = item / 2

            if row == 0 {
                // Top row
                newAttribute.frame.origin.y = sectionInset.top
            } else {
                // Bottom row
                newAttribute.frame.origin.y = sectionInset.top + itemSize.height + minimumInteritemSpacing
            }

            newAttribute.frame.origin.x = sectionInset.left + CGFloat(column) * (itemSize.width + minimumLineSpacing)

            newAttributes.append(newAttribute)
        }

        return newAttributes
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView, collectionView.numberOfSections > 0 else {
            return .zero
        }

        let itemCount = collectionView.numberOfItems(inSection: 0)
        let columnCount = (itemCount + 1) / 2 // Round up to account for odd numbers

        let width = sectionInset.left
            + CGFloat(columnCount) * itemSize.width
            + CGFloat(columnCount - 1) * minimumLineSpacing
            + sectionInset.right
        let height = collectionView.bounds.height

        return CGSize(width: width, height: height)
    }
}
