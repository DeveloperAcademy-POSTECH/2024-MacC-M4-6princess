//
//  CustomFlowLayout.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/18/25.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let centerX = collectionView?.contentOffset.x ?? 0 + (collectionView?.bounds.width ?? 0) / 2
        
        for attribute in attributes {
            let distance = attribute.center.x - centerX
            if attribute.indexPath.item == 0 {
                // 빈 셀은 그대로 둡니다
                continue
            } else if abs(distance) < (58 / 2) {
                attribute.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } else if distance > 0 && distance < (58 / 2 + 50 / 2) {
                let scale = 50 / 38
                attribute.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            } else {
                attribute.transform = .identity
            }
        }
        
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

