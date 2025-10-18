//
//  VerticallyCenteredTextView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//

import UIKit

final class VerticallyCenteredTextView: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 편집 중일 때는 중앙 정렬 해제
        guard !isFirstResponder else {
            textContainerInset.top = 0
            return
        }
        
        let contentHeight = contentSize.height
        let containerHeight = bounds.height
        let diff = containerHeight - contentHeight
        let top = diff > 0 ? floor(diff / 2) : 0
        
        textContainerInset = UIEdgeInsets(
            top: top,
            left: textContainerInset.left,
            bottom: 0,
            right: textContainerInset.right
        )
    }
}
