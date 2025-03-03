//
//  FilterCell.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import UIKit

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
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with image: UIImage, size: CGFloat, isSelected: Bool) {
        imageView.image = image
        
        self.frame.size = CGSize(width: size, height: size)
        self.layer.cornerRadius = size / 2
        self.clipsToBounds = true
        
        if isSelected {
            self.layer.borderWidth = 0
        } else {
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor(named: "PointPink")?.cgColor ?? UIColor.systemPink.cgColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        self.layer.borderWidth = 0
    }
}

//빈 셀
class EmptyCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 0
        self.layer.borderWidth = 0
        self.clipsToBounds = false
    }
    
    func configure() {
        // 추가적인 설정이 필요한 경우 여기에 구현
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 필요한 경우 재사용 준비 로직 추가
    }
}
