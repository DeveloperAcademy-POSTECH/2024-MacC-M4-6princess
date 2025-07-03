//
//  FilterCell.swift
//  InstaCamTest
//
//  Created by 김이예은 on 2/16/25.
//

import UIKit

class FilterCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit // 이미지 중앙 정렬 방식 변경
        iv.clipsToBounds = true
        return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 이미지 뷰를 셀 크기의 90%로 설정하여 여백 생성
//        imageView.frame = CGRect(
//            x: bounds.width * 0.05,
//            y: bounds.height * 0.05,
//            width: bounds.width * 0.9,
//            height: bounds.height * 0.9
//        )
//      이미지 뷰를 셀 전체에 맞춤
        imageView.frame = contentView.bounds
        // 원형 모양 설정
        let radius = min(contentView.bounds.width, contentView.bounds.height) / 2
        self.layer.cornerRadius = radius
        self.contentView.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.contentView.layer.masksToBounds = true
    }
    
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
        
        // // 선택된 셀은 항상 58pt, 선택되지 않은 셀은 전달받은 size 사용
        // let finalSize = isSelected ? 58 : size
        
        // // 셀 크기 설정
        // self.frame.size = CGSize(width: finalSize, height: finalSize)
        
        // // 원형 모양 설정
        // self.layer.cornerRadius = finalSize / 2
        // self.contentView.layer.cornerRadius = finalSize / 2
        // self.layer.masksToBounds = true
        // self.contentView.layer.masksToBounds = true
        
        // 선택 상태에 따른 테두리 설정
        if isSelected {
            self.layer.borderWidth = 0
            self.layer.borderColor = nil
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
    
    func configure() {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
