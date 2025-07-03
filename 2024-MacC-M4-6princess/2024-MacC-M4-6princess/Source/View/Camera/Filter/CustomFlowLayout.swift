//
//  CustomFlowLayout.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/18/25.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    // 셀 크기 상수
    let centerCellSize: CGFloat = 58
    let defaultCellSize: CGFloat = 38
    let emptyCellWidth: CGFloat = 58
    
    // 간격 상수
    let centerCellSpacing: CGFloat = 31
    let defaultCellSpacing: CGFloat = 20
    
    private let standardSpacing: CGFloat = 20
    private let centerSpacing: CGFloat = 31
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 첫 번째와 마지막 셀이 화면 중앙에 올 수 있도록 contentInset 설정
        let inset = (collectionView.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        // 스크롤 감속률 설정
        collectionView.decelerationRate = .normal
        
        minimumLineSpacing = standardSpacing
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() }) as? [UICollectionViewLayoutAttributes],
              let collectionView = collectionView else {
            return nil
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerCell = attributes.min { abs($0.center.x - centerX) < abs($1.center.x - centerX) }
        guard let centerCell = centerCell else { return attributes }
        
        // 1. 크기 먼저 지정
        for attribute in attributes {
            if attribute.indexPath.item == 0 {
                attribute.size = CGSize(width: emptyCellWidth, height: emptyCellWidth)
            } else if attribute.indexPath.item == centerCell.indexPath.item {
                attribute.size = CGSize(width: centerCellSize, height: centerCellSize)
            } else {
                attribute.size = CGSize(width: defaultCellSize, height: defaultCellSize)
            }
        }
        
        // 2. 위치 재배치 (중앙 셀 기준으로 좌우로 간격 유지)
        // 중앙 셀의 center.x를 기준으로 좌우로 배치
        let sorted = attributes.sorted { $0.indexPath.item < $1.indexPath.item }
        guard let centerIdx = sorted.firstIndex(where: { $0.indexPath.item == centerCell.indexPath.item }) else { return attributes }
        
        // 중앙 셀 위치 보정
        sorted[centerIdx].center.x = centerX
        
        // 왼쪽 셀들 배치
        for i in stride(from: centerIdx - 1, through: 0, by: -1) {
            let right = sorted[i + 1]
            let current = sorted[i]
            let spacing = (i + 1 == centerIdx) ? centerCellSpacing : defaultCellSpacing
            sorted[i].center.x = right.center.x - (right.size.width + current.size.width) / 2 - spacing
        }
        // 오른쪽 셀들 배치
        for i in (centerIdx + 1)..<sorted.count {
            let left = sorted[i - 1]
            let current = sorted[i]
            let spacing = (i - 1 == centerIdx) ? centerCellSpacing : defaultCellSpacing
            sorted[i].center.x = left.center.x + (left.size.width + current.size.width) / 2 + spacing
        }
        return sorted
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        // 아이템 개수와 간격을 기반으로 스크롤 가능한 영역 계산
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        // 빈 셀을 포함하여 전체 크기 계산
        let emptyAndSpacing = emptyCellWidth + defaultCellSpacing
        let defaultCellsWidth = CGFloat(itemCount - 3) * (defaultCellSize + defaultCellSpacing)
        let centerAndRightWidth = centerCellSize + centerCellSpacing + defaultCellSpacing
        
        // 최종 너비 계산
        let totalWidth = emptyAndSpacing + defaultCellsWidth + centerAndRightWidth
        
        // 여유 공간 추가
        return CGSize(width: totalWidth + defaultCellSize * 2, height: collectionView.bounds.height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        guard let attributes = layoutAttributesForElements(in: targetRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2
        
        var minDistance = CGFloat.greatestFiniteMagnitude
        var targetOffset = proposedContentOffset
        
        for attribute in attributes {
            let distance = abs(attribute.center.x - centerX)
            if distance < minDistance {
                minDistance = distance
                targetOffset.x = attribute.center.x - collectionView.bounds.width / 2
            }
        }
        
        // 애니메이션 속도 조정하는 곳
        let damping: CGFloat = 0.6
        let velocityMultiplier: CGFloat = velocity.x * damping
        targetOffset.x += velocityMultiplier
        
        return targetOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
