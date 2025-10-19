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

enum TextEditMode {
    case create  // 새 텍스트 생성
    case edit    // 기존 텍스트 수정
}

final class DFTextViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DFTextViewModel
    private let modiViewModel: DFModifyViewModel
    private let imageModel: ImageListModel
    private let frameManager: FrameManager?
    private let displayScale: CGFloat
    private let disposeBag = DisposeBag()
    
    private let editMode: TextEditMode
    private let initialStyle: TextStyle?
    
    // MARK: - UI Components
    
    private lazy var customTextView: VerticallyCenteredTextView = {
        let textView = VerticallyCenteredTextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.delegate = self
        
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        if let style = initialStyle {
            textView.attributedText = style.attributedString
            textView.font = style.font.applyFont(size: style.fontSize)
            textView.textAlignment = style.alignment.nsTextAlignment
            textView.textColor = UIColor(style.color)
        } else {
            textView.attributedText = viewModel.attributedTxt
            textView.font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
            textView.textAlignment = viewModel.textAlignment.nsTextAlignment
            textView.textColor = viewModel.selectedUIColor
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
        let minSize: Double = editMode == .edit ? 20 : 10
        let slider = TextSizeSlider(
            barSize: CGSize(width: 16, height: 200),
            minFontSize: minSize,
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
        frameManager: FrameManager? = nil,
        displayScale: CGFloat,
        editMode: TextEditMode = .create,
        initialStyle: TextStyle? = nil
    ) {
        self.viewModel = viewModel
        self.modiViewModel = modiViewModel
        self.imageModel = imageModel
        self.frameManager = frameManager
        self.displayScale = displayScale
        self.editMode = editMode
        self.initialStyle = initialStyle
        
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
        
        DispatchQueue.main.async { [weak self] in
            self?.customTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let style = initialStyle {
            loadInitialStyle(style)
        }
    }
    
    // MARK: - Setup
    
    private func loadInitialStyle(_ style: TextStyle) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.attributedTxt = style.attributedString
            self.viewModel.txt = style.txt
            self.viewModel.selectedColor = style.color
            self.viewModel.selectedUIColor = UIColor(style.color)
            self.viewModel.selectedFont = style.font
            self.viewModel.textAlignment = style.alignment
            self.viewModel.fontSize = style.fontSize
            
            if let colorIndex = self.viewModel.colorChip.firstIndex(of: style.color) {
                self.viewModel.colorNum = colorIndex
            }
            
            self.textSizeSlider.setFontSize(style.fontSize, animated: false)
            
            self.updateFontButtons()
            self.updateColorButtons()
            self.updateTextViewAlignment()
            self.updateAlignmentTabImage()
        }
    }
    
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
        
        updateTabSelection(selectedTab: 0)
    }
    
    private func setupConstraints() {
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let screenWidth = UIScreen.main.bounds.width
        
        customTextView.snp.makeConstraints { make in
            make.width.equalTo(screenWidth * 0.9)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
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
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.selectedFont = fontStyle
                self.updateFontButtons()
                self.updateTextViewFont()
            })
            .disposed(by: disposeBag)
        
        return button
    }
    
    private func setupColorButtons() {
        viewModel.colorChipUIColor.enumerated().forEach { index, color in
            let button = createColorButton(color: color, index: index)
            colorStackView.addArrangedSubview(button)
        }
    }
    
    private func createColorButton(color: UIColor, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        let size: CGFloat = viewModel.colorNum == index ? 40 : 30
        
        button.backgroundColor = color
        button.layer.cornerRadius = size / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        
        button.snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        
        button.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.selectedColor = self.viewModel.colorChip[index]
                self.viewModel.selectedUIColor = color
                self.viewModel.colorNum = index
                self.updateColorButtons()
                self.updateTextViewColor()
            })
            .disposed(by: disposeBag)
        
        return button
    }
    
    private func setupBindings() {
        textSizeSlider.fontSize
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] fontSize in
                guard let self = self else { return }
                self.viewModel.fontSize = fontSize
                self.updateTextViewFont()
            })
            .disposed(by: disposeBag)
        
        fontTabButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.tab = 0
                self.updateTabSelection(selectedTab: 0)
            })
            .disposed(by: disposeBag)
        
        colorTabButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.tab = 1
                self.updateTabSelection(selectedTab: 1)
            })
            .disposed(by: disposeBag)
        
        alignmentTabButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.tab = 2
                self.viewModel.toggleTextAlignment()
                self.updateTabSelection(selectedTab: 2)
                self.updateTextViewAlignment()
                self.updateAlignmentTabImage()
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .observe(on: MainScheduler.instance)
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
            .observe(on: MainScheduler.instance)
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
        
        let newStyle = TextStyle(
            attributedString: viewModel.attributedTxt ?? NSAttributedString(string: ""),
            txt: viewModel.txt,
            font: viewModel.selectedFont,
            color: viewModel.selectedColor,
            alignment: viewModel.textAlignment,
            fontSize: viewModel.fontSize
        )
        
        modiViewModel.style = newStyle
        
        switch editMode {
        case .create:
            createNewText()
            modiViewModel.showTextView = false
            
        case .edit:
            updateExistingText()
            frameManager?.showTextModifyView = false
        }
        
        dismiss(animated: true)
    }
    
    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard viewModel.tab == 2 else { return }
        guard gesture.state == .ended else { return }
        
        let translation = gesture.translation(in: customTextView)
        let direction: DFTextViewModel.SwipeDirection = translation.x < 0 ? .left : .right
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewModel.textAlignment = self.viewModel.computeNextAlignment(
                for: self.viewModel.textAlignment,
                direction: direction
            )
            self.updateTextViewAlignment()
            self.updateAlignmentTabImage()
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.fontStackView.arrangedSubviews.enumerated().forEach { index, view in
                guard let button = view as? UIButton else { return }
                let fontStyle = NewFontStyle.allCases[index]
                let isSelected = self.viewModel.selectedFont == fontStyle
                
                button.backgroundColor = isSelected ? .white : .clear
                button.setTitleColor(isSelected ? .black : .white, for: .normal)
            }
        }
    }
    
    private func updateColorButtons() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.colorStackView.arrangedSubviews.enumerated().forEach { index, view in
                guard let button = view as? UIButton else { return }
                let size: CGFloat = self.viewModel.colorNum == index ? 40 : 30
                
                UIView.animate(withDuration: 0.36) {
                    button.snp.updateConstraints { make in
                        make.width.height.equalTo(size)
                    }
                    button.layer.cornerRadius = size / 2
                    button.superview?.layoutIfNeeded()
                }
            }
        }
    }
    
    private func updateTextViewFont() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let font = self.viewModel.selectedFont.applyFont(size: self.viewModel.fontSize)
            self.customTextView.font = font
            
            if let attributedText = self.customTextView.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedText.addAttribute(
                    .font,
                    value: font,
                    range: NSRange(location: 0, length: mutableAttributedText.length)
                )
                self.customTextView.attributedText = mutableAttributedText
                self.viewModel.attributedTxt = mutableAttributedText
            }
        }
    }
    
    private func updateTextViewColor() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.customTextView.textColor = self.viewModel.selectedUIColor
            
            if let attributedText = self.customTextView.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedText.addAttribute(
                    .foregroundColor,
                    value: self.viewModel.selectedUIColor,
                    range: NSRange(location: 0, length: mutableAttributedText.length)
                )
                self.customTextView.attributedText = mutableAttributedText
                self.viewModel.attributedTxt = mutableAttributedText
            }
        }
    }
    
    private func updateTextViewAlignment() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.customTextView.textAlignment = self.viewModel.textAlignment.nsTextAlignment
        }
    }
    
    private func updateAlignmentTabImage() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let imageName = self.viewModel.imageForAlignment(self.viewModel.textAlignment)
            let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
            self.alignmentTabButton.setImage(image, for: .normal)
        }
    }
    
    private func updateLayoutForKeyboard(height: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let bottomControlsHeight: CGFloat = 120
        let availableHeight = screenHeight - height - bottomControlsHeight
        let textViewHeight = availableHeight * 0.6
        let textViewTop = (availableHeight - textViewHeight) / 2
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
            
            self.customTextView.snp.remakeConstraints { make in
                make.width.equalTo(screenWidth * 0.9)
                make.height.equalTo(textViewHeight)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(textViewTop)
            }
            
            self.tabBarView.snp.updateConstraints { make in
                let bottomPadding: CGFloat = height == 0 ? 20 : 5
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-(height + bottomPadding))
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Text Operations
    
    private func createNewText() {
        let newImage = SubjectImage()
        
        guard let image = viewModel.renderedImage else {
            print("Image not found")
            return
        }
        
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
        
        imageModel.imageList.forEach { $0.isTapped = false }
        imageModel.imageList.append(newImage)
        modiViewModel.selectedSubject = imageModel.imageList.last
        modiViewModel.selectedIndex = imageModel.imageList.indices.last
        
        if let lastImage = imageModel.imageList.last {
            modiViewModel.modelListControl(subject: lastImage)
        }
    }
    
    private func updateExistingText() {
        let newImage = SubjectImage()
        
        guard let image = viewModel.renderedImage else {
            print("Image not found")
            return
        }
        
        newImage.text = image
        newImage.originalImage = image
        newImage.textStyle = modiViewModel.style
        
        if let uuid = frameManager?.textUUID,
           let index = imageModel.imageList.firstIndex(where: { $0.id == uuid }) {
            
            imageModel.imageList[index] = newImage
            modiViewModel.selectedIndex = index
            modiViewModel.selectedSubject = newImage
            modiViewModel.modelListControl(subject: imageModel.imageList[index])
            
        } else {
            print("Error: Could not find text with UUID to update")
        }
        
        imageModel.imageList.forEach {
            if $0.isTapped {
                $0.isTapped = false
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension DFTextViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.viewModel.txt = textView.text
            self.viewModel.attributedTxt = textView.attributedText
            
            textView.textColor = self.viewModel.selectedUIColor
            
            let contentSize = textView.sizeThatFits(
                CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
            )
            self.viewModel.captureSize = contentSize
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 필요시 구현
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 필요시 구현
    }
}
