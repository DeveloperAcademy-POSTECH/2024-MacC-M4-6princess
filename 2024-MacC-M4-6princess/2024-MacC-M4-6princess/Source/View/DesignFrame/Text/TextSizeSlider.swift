//
//  TextSizeSlider.swift
//  2024-MacC-M4-6princess
//
//  Created by piri kim on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TextSizeSlider: UIView {
    
    // MARK: - Properties
    
    private let barSize: CGSize
    private let handleSize: CGFloat = 40
    private let minFontSize: Double
    private let maxFontSize: Double
    
    private let fontSizeRelay = BehaviorRelay<Double>(value: 20.0)
    private var lastFeedbackFontSize: Int = -1
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // 🔥 제약조건을 프로퍼티로 저장
    private var handleCenterYConstraint: Constraint?
    
    var fontSize: Observable<Double> {
        return fontSizeRelay.asObservable()
    }
    
    // MARK: - UI Components
    
    private lazy var barImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "textSizeBar"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private lazy var handleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "textSizeHandle"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // MARK: - Initialization
    
    init(barSize: CGSize, minFontSize: Double, maxFontSize: Double) {
        self.barSize = barSize
        self.minFontSize = minFontSize
        self.maxFontSize = maxFontSize
        super.init(frame: .zero)
        
        setupUI()
        setupConstraints()
        setupGestures()
        feedbackGenerator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(barImageView)
        addSubview(handleImageView)
    }
    
    private func setupConstraints() {
        barImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(barSize.width)
            make.height.equalTo(barSize.height)
        }
        
        // 🔥 초기 centerY 제약조건을 설정하고 저장
        handleImageView.snp.makeConstraints { make in
            make.centerX.equalTo(barImageView)
            make.width.height.equalTo(handleSize)
            // centerY 제약조건을 저장
            handleCenterYConstraint = make.centerY.equalTo(barImageView.snp.top).offset(computeHandleYPosition()).constraint
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        handleImageView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Actions
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: barImageView)
        let minY = handleSize / 2
        let maxY = barSize.height - handleSize / 2
        let clampedY = min(max(location.y, minY), maxY)
        
        let normalizedValue = 1.0 - Double((clampedY - minY) / (maxY - minY))
        let newFontSize = minFontSize + normalizedValue * (maxFontSize - minFontSize)
        
        fontSizeRelay.accept(newFontSize)
        updateHandlePosition(animated: true)
        
        // 햅틱 피드백
        let currentIntSize = Int(newFontSize.rounded())
        if currentIntSize != lastFeedbackFontSize {
            feedbackGenerator.impactOccurred()
            lastFeedbackFontSize = currentIntSize
        }
        
        if gesture.state == .began {
            feedbackGenerator.prepare()
        }
    }
    
    // MARK: - Helper Methods
    
    private func computeHandleYPosition() -> CGFloat {
        let currentFontSize = fontSizeRelay.value
        let normalizedValue = (currentFontSize - minFontSize) / (maxFontSize - minFontSize)
        let minY = handleSize / 2
        let maxY = barSize.height - handleSize / 2
        return minY + (maxY - minY) * CGFloat(1.0 - normalizedValue)
    }
    
    private func updateHandlePosition(animated: Bool) {
        let yPosition = computeHandleYPosition()
        
        let updateBlock = {
            // 🔥 저장된 제약조건의 constant를 직접 업데이트
            self.handleCenterYConstraint?.update(offset: yPosition)
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
    
    func setFontSize(_ fontSize: Double, animated: Bool = false) {
        fontSizeRelay.accept(fontSize)
        updateHandlePosition(animated: animated)
    }
}
