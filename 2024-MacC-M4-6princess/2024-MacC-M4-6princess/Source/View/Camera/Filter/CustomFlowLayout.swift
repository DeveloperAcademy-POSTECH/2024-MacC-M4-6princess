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
    let centerCellSize: CGFloat = 58 // 중앙 셀 크기
    let defaultCellSize: CGFloat = 38 // 기본 셀 크기
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        // 첫 번째와 마지막 셀이 화면 중앙에 올 수 있도록 contentInset 설정
        let inset = (collectionView.bounds.width - centerCellSize) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        // rect를 확장하여 화면 밖의 셀도 포함하도록 설정
        let extendedRect = rect.insetBy(dx: -1000, dy: 0)
        
        guard let attributes = super.layoutAttributesForElements(in: extendedRect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }
        
        // 컬렉션 뷰의 중앙 좌표 계산
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2 + 4 // 세로 중앙 위치
        
        var previousCellMaxX: CGFloat = centerCellSize // Empty 셀 너비 기준
        
        for attribute in attributes {
            if attribute.indexPath.item == 0 {
                // Empty 셀 고정
                attribute.frame.origin.x = 0
                attribute.zIndex = 1
                attribute.center.y = centerY
            } else {
                // 나머지 셀 배치
                attribute.center.y = centerY
                attribute.frame.origin.x = previousCellMaxX + defaultCellSpacing
                
                previousCellMaxX = attribute.frame.maxX
                
                // 중앙 근처 셀 강조 (크기와 zIndex 조정)
                let distanceFromCenter = abs(attribute.center.x - centerX)
                if distanceFromCenter < centerCellSize + centerCellSpacing {
                    attribute.frame.size = CGSize(width: centerCellSize, height: centerCellSize)
                    attribute.zIndex = 2
                } else {
                    attribute.frame.size = CGSize(width: defaultCellSize, height: defaultCellSize)
                    attribute.zIndex = 1
                }
            }
        }
        
        // 중앙 셀 찾기 및 위치 조정
        let centerCell = attributes.min { abs($0.center.x - centerX) < abs($1.center.x - centerX) }

        attributes.forEach { attr in
            if attr != centerCell {
                let distance = abs(attr.center.x - centerCell!.center.x)
                
                if distance < centerCellSize + centerCellSpacing + defaultCellSize {
                    let direction = attr.center.x > centerCell!.center.x ? 1 : -1
                    attr.center.x = centerCell!.center.x + CGFloat(direction) * (centerCellSize + centerCellSpacing)
                } else {
                    // 중앙 셀 주변이 아닌 경우 기본 간격 적용
                    if let index = attributes.firstIndex(of: attr), index > 0 {
                        let prevAttr = attributes[index - 1]
                        attr.frame.origin.x = prevAttr.frame.maxX + defaultCellSpacing
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
        let totalWidth = CGFloat(itemCount + 2) * (defaultCellSize + defaultCellSpacing)
        
        // 여유 공간 추가 없이 정확히 필요한 영역만 설정
        return CGSize(width: totalWidth, height: collectionView.bounds.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true // 스크롤 시 항상 레이아웃 갱신
    }
}
