//
//  CustomFlowLayout.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/18/25.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    let centerCellSize: CGFloat = 58
    let defaultCellSize: CGFloat = 38
    let emptyCellWidth: CGFloat = 58
    
    let centerCellSpacing: CGFloat = 31
    let defaultCellSpacing: CGFloat = 20
    
    private let standardSpacing: CGFloat = 20
    private let centerSpacing: CGFloat = 31
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        let inset = (collectionView.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.6)
        minimumLineSpacing = standardSpacing
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() }) as? [UICollectionViewLayoutAttributes],
              let collectionView = collectionView else {
            return nil
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let isScrolling = collectionView.isTracking || collectionView.isDecelerating
        
        // 중앙에 가장 가까운 셀 찾기
        var closestCell: UICollectionViewLayoutAttributes?
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for attribute in attributes {
            let distance = abs(attribute.center.x - centerX)
            if distance < minDistance {
                minDistance = distance
                closestCell = attribute
            }
        }
        
        guard let centerCell = closestCell else { return attributes }
        
        // 셀 크기 설정
        for attribute in attributes {
            if attribute.indexPath.item == 0 {
                attribute.size = CGSize(width: emptyCellWidth, height: emptyCellWidth)
            } else {
                let distance = abs(attribute.center.x - centerX)
                let maxDistance: CGFloat = 180.0
                
                let normalizedDistance = min(distance / maxDistance, 1.0)
                let sineProgress = sin((1.0 - normalizedDistance) * .pi / 2)
                let smoothedProgress = sineProgress * sineProgress
                
                let interpolatedSize = defaultCellSize + (centerCellSize - defaultCellSize) * smoothedProgress
                let finalSize = max(defaultCellSize, min(centerCellSize, interpolatedSize))
                
                attribute.size = CGSize(width: finalSize, height: finalSize)
            }
        }
        
        // 셀 위치 재배치 (스크롤 중에도 중앙 주위 간격 다르게 유지)
        var sorted = attributes.sorted { $0.indexPath.item < $1.indexPath.item }
        guard let centerIdx = sorted.firstIndex(where: { $0.indexPath.item == centerCell.indexPath.item }) else { return attributes }
        
        if !isScrolling {
            sorted[centerIdx].center.x = centerX
        }
        
        // 왼쪽 셀들 배치
        for i in stride(from: centerIdx - 1, through: 0, by: -1) {
            let right = sorted[i + 1]
            let current = sorted[i]
            
            let rightSizeRatio = (right.size.width - defaultCellSize) / (centerCellSize - defaultCellSize)
            let currentSizeRatio = (current.size.width - defaultCellSize) / (centerCellSize - defaultCellSize)
            let avgSizeRatio = (rightSizeRatio + currentSizeRatio) / 2
            
            let sineSpacingRatio = sin(avgSizeRatio * .pi / 2)
            let easedSpacingRatio = sineSpacingRatio * sineSpacingRatio
            
            let dynamicSpacing = defaultCellSpacing + (centerCellSpacing - defaultCellSpacing) * easedSpacingRatio
            
            sorted[i].center.x = right.center.x - (right.size.width + current.size.width) / 2 - dynamicSpacing
        }
        
        // 오른쪽 셀들 배치
        for i in (centerIdx + 1)..<sorted.count {
            let left = sorted[i - 1]
            let current = sorted[i]
            
            let leftSizeRatio = (left.size.width - defaultCellSize) / (centerCellSize - defaultCellSize)
            let currentSizeRatio = (current.size.width - defaultCellSize) / (centerCellSize - defaultCellSize)
            let avgSizeRatio = (leftSizeRatio + currentSizeRatio) / 2
            
            let sineSpacingRatio = sin(avgSizeRatio * .pi / 2)
            let easedSpacingRatio = sineSpacingRatio * sineSpacingRatio
            
            let dynamicSpacing = defaultCellSpacing + (centerCellSpacing - defaultCellSpacing) * easedSpacingRatio
            
            sorted[i].center.x = left.center.x + (left.size.width + current.size.width) / 2 + dynamicSpacing
        }
        
        return sorted
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let emptyAndSpacing = emptyCellWidth + defaultCellSpacing
        let defaultCellsWidth = CGFloat(itemCount - 3) * (defaultCellSize + defaultCellSpacing)
        let centerAndRightWidth = centerCellSize + centerCellSpacing + defaultCellSpacing
        let totalWidth = emptyAndSpacing + defaultCellsWidth + centerAndRightWidth
        
        // 왼쪽에 추가 여백 확보
        let extraPadding = collectionView.bounds.width // 화면 크기만큼 추가
        return CGSize(width: totalWidth + defaultCellSize * 2 + extraPadding, height: collectionView.bounds.height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        guard let layoutAttributes = layoutAttributesForElements(in: targetRect) else { return proposedContentOffset }
        
        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        var targetOffset = proposedContentOffset
        
        for attribute in layoutAttributes {
            let distance = abs(attribute.center.x - centerX)
            if distance < closestDistance {
                closestDistance = distance
                targetOffset.x = attribute.center.x - collectionView.bounds.width / 2
            }
        }
        
        return targetOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
