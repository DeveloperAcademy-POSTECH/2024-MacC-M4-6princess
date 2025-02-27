//
//  FilterCell.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import UIKit
import SwiftUI

class FilterCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func configure(with image: UIImage, isSelected: Bool) {
            imageView.image = image
            
            UIView.animate(withDuration: 0.2) {
                self.transform = isSelected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
                self.layer.cornerRadius = isSelected ? 29 : 8
                // 선택 표시를 테두리로만 하고 배경색은 제거
//                self.layer.borderWidth = isSelected ? 2 : 0
//                self.layer.borderColor = isSelected ? UIColor.blue.cgColor : nil
                self.backgroundColor = .clear
            }
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        transform = .identity
        layer.borderWidth = 0
    }
}
