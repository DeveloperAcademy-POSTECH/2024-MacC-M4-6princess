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
    let defaultCellSize: CGFloat = 38
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 첫 번째와 마지막 셀이 화면 중앙에 올 수 있도록 contentInset 설정
        let inset = (collectionView.bounds.width - 58) / 2  // 58은 Empty 셀 너비
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        // 확장된 rect를 사용하여 화면 밖의 셀도 포함하도록 함
        let extendedRect = CGRect(
            x: rect.origin.x - collectionView.bounds.width,
            y: rect.origin.y,
            width: rect.width + collectionView.bounds.width * 2,
            height: rect.height
        )
        
        guard let attributes = super.layoutAttributesForElements(in: extendedRect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }
        
        // 1. Empty 셀 항상 왼쪽 끝에 고정
        if let emptyCellAttr = attributes.first(where: { $0.indexPath.item == 0 }) {
            emptyCellAttr.frame.origin.x = 0
            emptyCellAttr.zIndex = 1
            emptyCellAttr.center.y = collectionView.bounds.height / 2 + 4
        }
        
        // 2. 필터 셀 레이아웃 계산
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
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
        let centerCell = attributes.min { abs($0.center.x - centerX) < abs($1.center.x - centerX) }

        if let centerCell = centerCell {
            for attr in attributes {
                if attr != centerCell {
                    let distance = abs(attr.center.x - centerCell.center.x)
                    if distance < 58 + centerCellSpacing + 50 {
                        let direction = attr.center.x > centerCell.center.x ? 1 : -1
                        attr.center.x = centerCell.center.x + CGFloat(direction) * (54 + centerCellSpacing)
                    } else {
                        // 중앙 셀 주변이 아닌 경우 기본 간격 적용
                        if let index = attributes.firstIndex(of: attr), index > 0 {
                            let prevAttr = attributes[index - 1]
                            attr.frame.origin.x = prevAttr.frame.maxX + defaultCellSpacing
                        }
                    }
                }
            }
        }
        
        return attributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        // 아이템 개수와 간격을 기반으로 스크롤 가능한 영역 계산
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        // 첫 번째 셀(Empty 셀)은 58, 나머지는 defaultCellSize
        let totalWidth = 58 + CGFloat(itemCount - 1) * (defaultCellSize + defaultCellSpacing) + defaultCellSpacing
        
        // 여유 공간 추가
        return CGSize(width: totalWidth + defaultCellSize * 2, height: collectionView.bounds.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
