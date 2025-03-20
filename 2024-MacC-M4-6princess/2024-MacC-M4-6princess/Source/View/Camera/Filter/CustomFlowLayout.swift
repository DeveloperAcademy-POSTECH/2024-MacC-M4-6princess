//
//  CustomFlowLayout.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/18/25.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    let centerCellSpacing: CGFloat = 31
    let defaultCellSpacing: CGFloat = 20
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }),
              let collectionView = collectionView else {
            return nil
        }
        
        // 1. Empty 셀 항상 왼쪽 끝에 고정
        if let emptyCellAttr = attributes.first(where: { $0.indexPath.item == 0 }) {
            emptyCellAttr.frame.origin.x = 0
            emptyCellAttr.zIndex = 1
            emptyCellAttr.center.y = collectionView.bounds.height
        }
        
        // 2. 필터 셀 레이아웃 계산
//        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2 + 4 // 세로 중앙 위치

        var previousCellMaxX: CGFloat = 58 // Empty 셀 너비 기준
        
        for attribute in attributes where attribute.indexPath.item > 0 {
            // 3. 세로 중앙 정렬
            attribute.center.y = centerY
            
            // 4. 초기 위치 설정 (기본 간격 20)
            attribute.frame.origin.x = previousCellMaxX + defaultCellSpacing
            previousCellMaxX = attribute.frame.maxX
        }
        // 중앙 셀 찾기
            let centerX = collectionView.bounds.midX
            let centerCell = attributes.min { abs($0.center.x - centerX) < abs($1.center.x - centerX) }
            
            attributes.forEach { attr in
                if attr != centerCell {
                    let distance = abs(attr.center.x - centerCell!.center.x)
                    if distance < 58 + centerCellSpacing + 50 {
                        let direction = attr.center.x > centerCell!.center.x ? 1 : -1
                        attr.center.x = centerCell!.center.x + CGFloat(direction) * (54 + centerCellSpacing)
                    }
                }
            }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

// Float 비교를 위한 연산자
infix operator ≈≈ : ComparisonPrecedence
extension CGFloat {
    static func ≈≈(lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) < 2.0
    }
}
