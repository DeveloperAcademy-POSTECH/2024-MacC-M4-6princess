//
//  DFTextViewController.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwiftUI

final class DFTextViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DFTextViewModel
    private let modiViewModel: DFModifyViewModel
    private let imageModel: ImageListModel
    private let displayScale: CGFloat
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private lazy var customTextView: VerticallyCenteredTextView = {
        let textView = VerticallyCenteredTextView()
        textView.attributedText = viewModel.attributedTxt
        textView.font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        textView.textAlignment = viewModel.textAlignment.nsTextAlignment
        textView.textColor = UIColor(viewModel.selectedColor)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.delegate = self
        
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        return textView
    }()
    
    private lazy var fontScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var fontStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var colorScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private lazy var colorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var fontTabButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aa", size: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.tag = 0
        return button
    }()
    
    private lazy var colorTabButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "df.colorChip")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.tag = 1
        return button
    }()
    
    private lazy var alignmentTabButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: viewModel.imageForAlignment(viewModel.textAlignment))?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.tag = 2
        return button
    }()
    
    private lazy var textSizeSlider: TextSizeSlider = {
        let slider = TextSizeSlider(
            barSize: CGSize(width: 16, height: 200),
            minFontSize: 10,
            maxFontSize: 60
        )
        return slider
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    // MARK: - Initialization
    
    init(
        viewModel: DFTextViewModel,
        modiViewModel: DFModifyViewModel,
        imageModel: ImageListModel,
        displayScale: CGFloat
    ) {
        self.viewModel = viewModel
        self.modiViewModel = modiViewModel
        self.imageModel = imageModel
        self.displayScale = displayScale
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        setupFontButtons()
        setupColorButtons()
        setupBindings()
        setupGestures()
        
        // 키보드 자동 표시
        DispatchQueue.main.async { [weak self] in
            self?.customTextView.becomeFirstResponder()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(overlayView)
        view.addSubview(customTextView)
        view.addSubview(textSizeSlider)
        view.addSubview(fontScrollView)
        view.addSubview(colorScrollView)
        view.addSubview(tabBarView)
        
        fontScrollView.addSubview(fontStackView)
        colorScrollView.addSubview(colorStackView)
        
        tabBarView.addSubview(fontTabButton)
        tabBarView.addSubview(colorTabButton)
        tabBarView.addSubview(alignmentTabButton)
        
        // 초기 탭 상태 설정
        updateTabSelection(selectedTab: 0)
    }
    
    private func setupConstraints() {
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        customTextView.snp.makeConstraints { make in
            make.width.equalTo(screenWidth * 0.9)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        
        textSizeSlider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalTo(customTextView)
            make.width.equalTo(50)
            make.height.equalTo(200)
        }
        
        tabBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        fontTabButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(tabBarView.snp.width).dividedBy(3).offset(-10)
        }
        
        colorTabButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(tabBarView.snp.width).dividedBy(3).offset(-10)
        }
        
        alignmentTabButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(tabBarView.snp.width).dividedBy(3).offset(-10)
        }
        
        fontScrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(tabBarView.snp.top).offset(-10)
            make.height.equalTo(50)
        }
        
        colorScrollView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tabBarView.snp.top).offset(-10)
            make.width.equalTo(335)
            make.height.equalTo(50)
        }
        
        fontStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
            make.height.equalTo(fontScrollView)
        }
        
        colorStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
            make.height.equalTo(colorScrollView)
        }
        
        // 초기 상태: 폰트 스크롤뷰만 표시
        colorScrollView.isHidden = true
    }
    
    private func setupNavigationBar() {
        let doneButton = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setupFontButtons() {
        NewFontStyle.allCases.forEach { fontStyle in
            let button = createFontButton(fontStyle: fontStyle)
            fontStackView.addArrangedSubview(button)
        }
    }
    
    private func createFontButton(fontStyle: NewFontStyle) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(fontStyle.displayName, for: .normal)
        button.titleLabel?.font = fontStyle.applyFont(size: 18)
        button.setTitleColor(.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        let isSelected = viewModel.selectedFont == fontStyle
        button.backgroundColor = isSelected ? .white : .clear
        button.setTitleColor(isSelected ? .black : .white, for: .normal)
        
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.selectedFont = fontStyle
                self?.updateFontButtons()
                self?.updateTextViewFont()
            })
            .disposed(by: disposeBag)
        
        return button
    }
    
    private func setupColorButtons() {
        viewModel.colorChip.enumerated().forEach { index, color in
            let button = createColorButton(color: color, index: index)
            colorStackView.addArrangedSubview(button)
        }
    }
    
    private func createColorButton(color: Color, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        let size: CGFloat = viewModel.colorNum == index ? 40 : 30
        
        button.backgroundColor = UIColor(color)
        button.layer.cornerRadius = size / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        button.snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.selectedColor = color
                self?.viewModel.colorNum = index
                self?.updateColorButtons()
                self?.updateTextViewColor()
            })
            .disposed(by: disposeBag)
        
        return button
    }
    
    private func setupBindings() {
        // 폰트 사이즈 슬라이더 바인딩
        textSizeSlider.fontSize
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] fontSize in
                self?.viewModel.fontSize = fontSize
                self?.updateTextViewFont()
            })
            .disposed(by: disposeBag)
        
        // 탭 버튼 바인딩
        fontTabButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.tab = 0
                self?.updateTabSelection(selectedTab: 0)
            })
            .disposed(by: disposeBag)
        
        colorTabButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.tab = 1
                self?.updateTabSelection(selectedTab: 1)
            })
            .disposed(by: disposeBag)
        
        alignmentTabButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.tab = 2
                self.viewModel.toggleTextAlignment()
                self.updateTabSelection(selectedTab: 2)
                self.updateTextViewAlignment()
                self.updateAlignmentTabImage()
            })
            .disposed(by: disposeBag)
        
        // 키보드 높이 관찰
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                return keyboardFrame.height - safeAreaBottom
            }
            .subscribe(onNext: { [weak self] height in
                self?.updateLayoutForKeyboard(height: height)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.updateLayoutForKeyboard(height: 0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupGestures() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        customTextView.addGestureRecognizer(swipeGesture)
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        viewModel.captureTextView(from: customTextView)
        imageToCoredata()
        
        modiViewModel.style = TextStyle(
            attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""),
            txt: viewModel.txt,
            font: viewModel.selectedFont,
            color: viewModel.selectedColor,
            alignment: viewModel.textAlignment,
            fontSize: viewModel.fontSize
        )
        
        modiViewModel.showTextView = false
        dismiss(animated: true)
    }
    
    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard viewModel.tab == 2 else { return }
        guard gesture.state == .ended else { return }
        
        let translation = gesture.translation(in: customTextView)
        let direction: DFTextViewModel.SwipeDirection = translation.x < 0 ? .left : .right
        
        viewModel.textAlignment = viewModel.computeNextAlignment(
            for: viewModel.textAlignment,
            direction: direction
        )
        
        updateTextViewAlignment()
        updateAlignmentTabImage()
    }
    
    // MARK: - Helper Methods
    
    private func updateTabSelection(selectedTab: Int) {
        fontTabButton.backgroundColor = selectedTab == 0 ? .white : .clear
        colorTabButton.backgroundColor = selectedTab == 1 ? .white : .clear
        alignmentTabButton.backgroundColor = selectedTab == 2 ? .white : .clear
        
        fontScrollView.isHidden = selectedTab != 0
        colorScrollView.isHidden = selectedTab != 1
    }
    
    private func updateFontButtons() {
        fontStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            let fontStyle = NewFontStyle.allCases[index]
            let isSelected = viewModel.selectedFont == fontStyle
            
            button.backgroundColor = isSelected ? .white : .clear
            button.setTitleColor(isSelected ? .black : .white, for: .normal)
        }
    }
    
    private func updateColorButtons() {
        colorStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let button = view as? UIButton else { return }
            let size: CGFloat = viewModel.colorNum == index ? 40 : 30
            
            UIView.animate(withDuration: 0.36) {
                button.snp.updateConstraints { make in
                    make.width.height.equalTo(size)
                }
                button.layer.cornerRadius = size / 2
                button.superview?.layoutIfNeeded()
            }
        }
    }
    
    private func updateTextViewFont() {
        let font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        customTextView.font = font
        
        if let attributedText = customTextView.attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttribute(
                .font,
                value: font,
                range: NSRange(location: 0, length: mutableAttributedText.length)
            )
            customTextView.attributedText = mutableAttributedText
            viewModel.attributedTxt = mutableAttributedText
        }
    }
    
    private func updateTextViewColor() {
        customTextView.textColor = UIColor(viewModel.selectedColor)
        
        if let attributedText = customTextView.attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttribute(
                .foregroundColor,
                value: UIColor(viewModel.selectedColor),
                range: NSRange(location: 0, length: mutableAttributedText.length)
            )
            customTextView.attributedText = mutableAttributedText
            viewModel.attributedTxt = mutableAttributedText
        }
    }
    
    private func updateTextViewAlignment() {
        customTextView.textAlignment = viewModel.textAlignment.nsTextAlignment
    }
    
    private func updateAlignmentTabImage() {
        let imageName = viewModel.imageForAlignment(viewModel.textAlignment)
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        alignmentTabButton.setImage(image, for: .normal)
    }
    
    private func updateLayoutForKeyboard(height: CGFloat) {
        let availableHeight = UIScreen.main.bounds.height - height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.customTextView.snp.remakeConstraints { make in
                let screenWidth = UIScreen.main.bounds.width
                make.width.equalTo(screenWidth * 0.9)
                make.height.equalTo(availableHeight * 0.6)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-height / 2)
            }
            
            self.tabBarView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(height == 0 ? -20 : -(height + 5))
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func imageToCoredata() {
        let newImage = SubjectImage()
        
        if let image = viewModel.renderedImage {
            newImage.text = image
            newImage.originalImage = image
            
            if let att = viewModel.attributedTxt {
                newImage.textStyle = TextStyle(
                    attributedString: att,
                    txt: viewModel.txt,
                    font: viewModel.selectedFont,
                    color: viewModel.selectedColor,
                    alignment: viewModel.textAlignment,
                    fontSize: viewModel.fontSize
                )
            }
            
            // 모든 이미지의 선택을 해제
            imageModel.imageList.forEach { $0.isTapped = false }
            
            imageModel.imageList.append(newImage)
            modiViewModel.selectedSubject = imageModel.imageList.last
            modiViewModel.selectedIndex = imageModel.imageList.indices.last
            
            if let lastImage = imageModel.imageList.last {
                modiViewModel.modelListControl(subject: lastImage)
            }
        } else {
            print("Image not found")
        }
    }
}

// MARK: - UITextViewDelegate

extension DFTextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.txt = textView.text
        viewModel.attributedTxt = textView.attributedText
        
        textView.textColor = UIColor(viewModel.selectedColor)
        
        let contentSize = textView.sizeThatFits(
            CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        )
        viewModel.captureSize = contentSize
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 필요시 구현
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 필요시 구현
    }
}
