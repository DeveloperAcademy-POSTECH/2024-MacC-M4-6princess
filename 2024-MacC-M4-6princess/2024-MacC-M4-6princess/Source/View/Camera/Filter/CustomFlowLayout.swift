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
    let rightOfCenterCellSize: CGFloat = 50
    let defaultCellSize: CGFloat = 38
    let emptyCellWidth: CGFloat = 58
    
    // 간격 상수
    let centerCellSpacing: CGFloat = 31
    let defaultCellSpacing: CGFloat = 20
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 첫 번째와 마지막 셀이 화면 중앙에 올 수 있도록 contentInset 설정
        let inset = (collectionView.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        // 스크롤 감속률 설정
        collectionView.decelerationRate = .normal
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
        
        // 화면 중앙 X 좌표
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2 + 4 // 세로 중앙 위치
        
        // 1. Empty 셀 항상 왼쪽 끝에 고정
        if let emptyCellAttr = attributes.first(where: { $0.indexPath.item == 0 }) {
            emptyCellAttr.frame.origin.x = 0
            emptyCellAttr.size = CGSize(width: emptyCellWidth, height: emptyCellWidth)
            emptyCellAttr.zIndex = 1
            emptyCellAttr.center.y = centerY
        }
        
        // 2. 중앙에 가장 가까운 셀 찾기
        let centerCell = attributes.min { abs($0.center.x - centerX) < abs($1.center.x - centerX) }
        
        // 3. 모든 셀의 세로 위치 설정 및 초기 위치 계산
        var previousCellMaxX: CGFloat = emptyCellWidth // Empty 셀 너비 기준
        
        for attr in attributes.sorted(by: { $0.indexPath.item < $1.indexPath.item }) where attr.indexPath.item > 0 {
            // 세로 중앙 정렬
            attr.center.y = centerY
            
            // 셀 크기 설정
            if attr == centerCell {
                attr.size = CGSize(width: centerCellSize, height: centerCellSize)
            } else if attr.indexPath.item == centerCell?.indexPath.item.advanced(by: 1) {
                attr.size = CGSize(width: rightOfCenterCellSize, height: rightOfCenterCellSize)
            } else {
                attr.size = CGSize(width: defaultCellSize, height: defaultCellSize)
            }
            
            // 초기 위치 설정
            attr.frame.origin.x = previousCellMaxX + defaultCellSpacing
            previousCellMaxX = attr.frame.maxX
        }
        
        // 4. 중앙 셀 및 주변 셀 위치 조정
        if let centerCell = centerCell {
            // 중앙 셀 정확히 중앙에 위치
            centerCell.center.x = centerX
            
            // 중앙 셀 오른쪽에 있는 셀들 조정
            let rightCells = attributes.filter { $0.center.x > centerCell.center.x && $0.indexPath.item > 0 }
                                     .sorted { $0.indexPath.item < $1.indexPath.item }
            
            var lastRightX = centerCell.center.x + centerCellSize / 2
            
            for (index, attr) in rightCells.enumerated() {
                if index == 0 {
                    // 중앙 셀 바로 오른쪽 셀 간격: centerCellSpacing
                    attr.size = CGSize(width: rightOfCenterCellSize, height: rightOfCenterCellSize)
                    attr.frame.origin.x = lastRightX + centerCellSpacing
                    lastRightX = attr.frame.maxX
                } else {
                    // 나머지 오른쪽 셀들 간격: defaultCellSpacing
                    attr.size = CGSize(width: defaultCellSize, height: defaultCellSize)
                    attr.frame.origin.x = lastRightX + defaultCellSpacing
                    lastRightX = attr.frame.maxX
                }
            }
            
            // 중앙 셀 왼쪽에 있는 셀들 조정
            let leftCells = attributes.filter { $0.center.x < centerCell.center.x && $0.indexPath.item > 0 }
                                    .sorted { $0.indexPath.item > $1.indexPath.item }
            
            var lastLeftX = centerCell.frame.minX
            
            for attr in leftCells {
                // 모든 왼쪽 셀들 (간격: defaultCellSpacing 또는 centerCellSpacing)
                attr.size = CGSize(width: defaultCellSize, height: defaultCellSize)
                
                // 중앙 셀 바로 왼쪽 셀인 경우 centerCellSpacing 사용
                if attr.indexPath.item == centerCell.indexPath.item - 1 {
                    attr.frame.origin.x = lastLeftX - centerCellSpacing - attr.size.width
                } else {
                    attr.frame.origin.x = lastLeftX - defaultCellSpacing - attr.size.width
                }
                lastLeftX = attr.frame.minX
            }
        }
        
        return attributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        // 아이템 개수와 간격을 기반으로 스크롤 가능한 영역 계산
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        // 빈 셀을 포함하여 전체 크기 계산
        let emptyAndSpacing = emptyCellWidth + defaultCellSpacing
        let defaultCellsWidth = CGFloat(itemCount - 3) * (defaultCellSize + defaultCellSpacing)
        let centerAndRightWidth = centerCellSize + centerCellSpacing + rightOfCenterCellSize + defaultCellSpacing
        
        // 최종 너비 계산
        let totalWidth = emptyAndSpacing + defaultCellsWidth + centerAndRightWidth
        
        // 여유 공간 추가
        return CGSize(width: totalWidth + defaultCellSize * 2, height: collectionView.bounds.height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        // 제안된 위치에서의 화면 영역
        let targetRect = CGRect(
            x: proposedContentOffset.x - collectionView.bounds.width / 2,
            y: 0,
            width: collectionView.bounds.width * 2,
            height: collectionView.bounds.height
        )
        
        // 해당 영역에 있는 모든 레이아웃 속성 가져오기
        guard let attributes = layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }
        
        // 화면 중앙 X 좌표
        let horizontalCenter = proposedContentOffset.x + collectionView.bounds.width / 2
        
        // 중앙에 가장 가까운 셀 찾기 (빈 셀 포함)
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        var targetOffset = proposedContentOffset
        
        for attr in attributes {
            let distance = abs(attr.center.x - horizontalCenter)
            if distance < closestDistance {
                closestDistance = distance
                // 셀이 정확히 중앙에 오도록 offset 계산
                targetOffset.x = attr.center.x - collectionView.bounds.width / 2
            }
        }
        
        return targetOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
