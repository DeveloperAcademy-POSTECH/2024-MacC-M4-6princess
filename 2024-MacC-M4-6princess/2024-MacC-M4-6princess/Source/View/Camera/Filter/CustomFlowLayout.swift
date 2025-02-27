//
//  CustomFlowLayout.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/18/25.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: FilterCollectionViewController?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard let collectionView = collectionView else { return attributes }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        return attributes.map { attr in
            let copy = attr.copy() as! UICollectionViewLayoutAttributes
            if let delegate = delegate {
                let currentFilter = delegate.filterImages[attr.indexPath.item].uuid
                let isSelected = currentFilter == delegate.currentSelectedFilter
                
                // 중앙으로부터의 거리 계산
                let distance = abs(attr.center.x - centerX)
                let standardWidth = delegate.normalCellWidth
                let standardHeight = delegate.normalCellHeight
                
                if isSelected {
                    copy.size = CGSize(width: delegate.selectedCellSize, height: delegate.selectedCellSize)
                } else {
                    // 거리에 따른 크기 조절
                    let scale: CGFloat
                    if distance < collectionView.bounds.width / 2 {
                        // 바로 옆 버튼
                        scale = 0.95
                    } else if distance < collectionView.bounds.width {
                        // 그 다음 버튼
                        scale = 0.85
                    } else {
                        // 더 멀리 있는 버튼
                        scale = 0.85
                    }
                    
                    copy.size = CGSize(
                        width: standardWidth * scale,
                        height: standardHeight * scale
                    )
                }
            }
            return copy
        }
    }
    
    // 스크롤 시 실시간 업데이트를 위해 추가
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

