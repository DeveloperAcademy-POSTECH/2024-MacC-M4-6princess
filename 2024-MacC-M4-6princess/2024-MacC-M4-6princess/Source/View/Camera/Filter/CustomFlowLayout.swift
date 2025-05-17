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
        
        
        for attribute in attributes {
            if attribute.indexPath.item == 0 {
                // Empty cell maintains constant size
                attribute.size = CGSize(width: emptyCellWidth, height: emptyCellWidth)
                continue
            }
            
            let distanceFromCenter = abs(attribute.center.x - centerX)
            
            // 부드러운 움직임을 위한 거리 계산
            let size: CGFloat
            let maxTransitionDistance: CGFloat = 100 // 전환 거리 증가
            
            if distanceFromCenter <= maxTransitionDistance {
                // 부드러운 크기 전환을 위한 progress 계산 (0.0 ~ 1.0)
                let progress = distanceFromCenter / maxTransitionDistance
                
                // Cubic easing function for smoother transition
                let easedProgress = progress * progress * (3 - 2 * progress)
                
                if attribute.indexPath.item == centerCell.indexPath.item {
                    // 중앙셀
                    size = centerCellSize
                } else if attribute.indexPath.item == centerCell.indexPath.item + 1 {
                    // 중앙 바로 오른쪽 셀
                    let sizeRange = centerCellSize - rightOfCenterCellSize
                    size = centerCellSize - (sizeRange * easedProgress)
                } else if attribute.indexPath.item == centerCell.indexPath.item - 1 {
                    // 중앙 바로 왼쪽 셀
                    let sizeRange = rightOfCenterCellSize - defaultCellSize
                    size = rightOfCenterCellSize - (sizeRange * easedProgress)
                } else {
                    // 나머지 셀
                    let sizeRange = rightOfCenterCellSize - defaultCellSize
                    size = defaultCellSize + (sizeRange * (1 - easedProgress))
                }
            } else {
                size = defaultCellSize
            }
            
            attribute.size = CGSize(width: size, height: size)
            
            // Adjust spacing around center cell
            if attribute.center.x < centerCell.center.x {
                // 중앙 기준 왼쪽
                if attribute.indexPath.item == centerCell.indexPath.item - 1 {
                    // 바로 옆 간격 31로 조정
                    let offset = centerCellSpacing + (attribute.size.width + centerCell.size.width) / 2
                    attribute.center.x = centerCell.center.x - offset
                } else {
                    // 나머지 셀들엔 20으로 설정
                    let previousAttribute = attributes.first { $0.indexPath.item == attribute.indexPath.item + 1 }
                    if let previous = previousAttribute {
                        let offset = standardSpacing + (attribute.size.width + previous.size.width) / 2
                        attribute.center.x = previous.center.x - offset
                    }
                }
            } else if attribute.center.x > centerCell.center.x {
                // 중앙 기준 오른쪽
                if attribute.indexPath.item == centerCell.indexPath.item + 1 {
                    // 바로 옆 간격 31로 조정
                    let offset = centerCellSpacing + (attribute.size.width + centerCell.size.width) / 2
                    attribute.center.x = centerCell.center.x + offset
                } else {
                    // 나머지 셀들엔 20으로 설정
                    let previousAttribute = attributes.first { $0.indexPath.item == attribute.indexPath.item - 1 }
                    if let previous = previousAttribute {
                        let offset = standardSpacing + (attribute.size.width + previous.size.width) / 2
                        attribute.center.x = previous.center.x + offset
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
