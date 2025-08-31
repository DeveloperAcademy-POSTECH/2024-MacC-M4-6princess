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
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        
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
