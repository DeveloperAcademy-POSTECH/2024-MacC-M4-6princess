//
//  DFTextViewController.swift
//  2024-MacC-M4-6princess
//
//  Created by 잠만보김쥬디 on 10/18/25.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DFTextViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DFTextViewModel
    private let modiViewModel: DFModifyViewModel
    private let disposeBag = DisposeBag()
    
    private var keyboardHeight: CGFloat = 0
    private var bottomControlsHeight: CGFloat = 0
    
    // MARK: - UI Components
    
    private lazy var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        textView.isScrollEnabled = true
        textView.delegate = self
        
        if #available(iOS 18.0, *) {
            textView.supportsAdaptiveImageGlyph = true
        }
        
        // 스와이프 제스처 추가
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeftGesture.direction = .left
        textView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRightGesture.direction = .right
        textView.addGestureRecognizer(swipeRightGesture)
        
        return textView
    }()
    
    private lazy var fontSizeSlider: VerticalSlider = {
        let slider = VerticalSlider()
        slider.minimumValue = 10
        slider.maximumValue = 60
        slider.value = Float(viewModel.fontSize)
        return slider
    }()
    
    private lazy var bottomControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var fontSelectorContainerView = UIView()
    private lazy var colorSelectorContainerView = UIView()
    private lazy var tabBarContainerView = UIView()
    
    // MARK: - Initialization
    
    init(viewModel: DFTextViewModel, modiViewModel: DFModifyViewModel) {
        self.viewModel = viewModel
        self.modiViewModel = modiViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardNotifications()
        setupBindings()
        
        updateTextViewStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedBackgroundView)
        view.addSubview(textView)
        view.addSubview(fontSizeSlider)
        view.addSubview(bottomControlsStackView)
        
        dimmedBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        textView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalTo(300)
        }
        
        fontSizeSlider.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(200)
        }
        
        bottomControlsStackView.addArrangedSubview(fontSelectorContainerView)
        bottomControlsStackView.addArrangedSubview(colorSelectorContainerView)
        bottomControlsStackView.addArrangedSubview(tabBarContainerView)
        
        bottomControlsStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        fontSelectorContainerView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        colorSelectorContainerView.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        tabBarContainerView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        // 초기에는 숨김
        fontSelectorContainerView.isHidden = true
        colorSelectorContainerView.isHidden = true
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(completeButtonTapped)
        )
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupBindings() {
        // 폰트 크기 슬라이더
        fontSizeSlider.rx.value
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.viewModel.fontSize = CGFloat(value)
                self.updateTextViewStyle()
                
                // 햅틱 피드백
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            })
            .disposed(by: disposeBag)
        
        // TODO: viewModel.tab 변경 시 하단 컨트롤 전환
        // RxSwift로 바인딩하거나 별도 메서드로 구현
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        guard let capturedImage = captureTextView() else { return }
        
        // ViewModel 업데이트
        modiViewModel.style = TextStyle(
            attributedString: textView.attributedText,
            txt: textView.text,
            font: viewModel.selectedFont,
            color: viewModel.selectedColor,
            alignment: viewModel.textAlignment,
            fontSize: viewModel.fontSize
        )
        
        // CoreData에 저장 (imageModel이 필요하면 파라미터로 전달받아야 함)
        // imageToCoredata(image: capturedImage, imageModel: imageModel)
        
        modiViewModel.showTextView = false
        dismiss(animated: true)
    }
    
    @objc private func handleSwipeLeft() {
        guard viewModel.tab == 2 else { return }
        viewModel.textAlignment = viewModel.computeNextAlignment(
            for: viewModel.textAlignment,
            direction: .left
        )
        updateTextViewStyle()
    }
    
    @objc private func handleSwipeRight() {
        guard viewModel.tab == 2 else { return }
        viewModel.textAlignment = viewModel.computeNextAlignment(
            for: viewModel.textAlignment,
            direction: .right
        )
        updateTextViewStyle()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        keyboardHeight = keyboardFrame.height
        updateLayoutForKeyboard(duration: duration)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        keyboardHeight = 0
        updateLayoutForKeyboard(duration: duration)
    }
    
    // MARK: - Private Methods
    
    private func updateLayoutForKeyboard(duration: TimeInterval) {
        // 하단 컨트롤의 실제 높이 계산
        bottomControlsStackView.layoutIfNeeded()
        bottomControlsHeight = bottomControlsStackView.frame.height + 40 // 20(top) + 20(bottom) padding
        
        // 키보드 위 남은 공간 계산
        let totalBottomSpace = keyboardHeight + bottomControlsHeight
        let availableHeight = view.bounds.height - totalBottomSpace
        
        UIView.animate(withDuration: duration) {
            // 하단 컨트롤을 키보드 위로 이동
            self.bottomControlsStackView.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-(20 + self.keyboardHeight))
            }
            
            // 텍스트뷰를 남은 공간의 중앙에 배치
            self.textView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset((availableHeight - 300) / 2)
                $0.width.equalToSuperview().multipliedBy(0.9)
                $0.height.equalTo(300)
            }
            
            // 슬라이더도 남은 공간의 중앙에 배치
            self.fontSizeSlider.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(5)
                $0.centerY.equalToSuperview().offset(-totalBottomSpace / 2)
                $0.width.equalTo(40)
                $0.height.equalTo(200)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateTextViewStyle() {
        textView.font = viewModel.selectedFont.applyFont(size: viewModel.fontSize)
        textView.textAlignment = NSTextAlignment(viewModel.textAlignment)
        textView.textColor = UIColor(color: viewModel.selectedColor)
        
        if let attributedText = viewModel.attributedTxt {
            textView.attributedText = attributedText
        }
    }
    
    private func captureTextView() -> UIImage? {
        let captureSize = textView.sizeThatFits(CGSize(
            width: textView.bounds.width,
            height: .greatestFiniteMagnitude
        ))
        
        let renderer = UIGraphicsImageRenderer(size: captureSize)
        return renderer.image { context in
            textView.drawHierarchy(in: CGRect(origin: .zero, size: captureSize), afterScreenUpdates: true)
        }
    }
    
    private func imageToCoredata(image: UIImage, imageModel: ImageListModel) {
        let newImage = SubjectImage()
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
        
        // 새로 추가한 이미지를 제외하고 모든 이미지의 선택을 해제
        imageModel.imageList.forEach {
            if $0.isTapped {
                $0.isTapped = false
            }
        }
        
        imageModel.imageList.append(newImage)
        modiViewModel.selectedSubject = imageModel.imageList.last
        modiViewModel.selectedIndex = imageModel.imageList.indices.last
        
        if let lastImage = imageModel.imageList.last {
            modiViewModel.modelListControl(subject: lastImage)
        }
    }
}

// MARK: - UITextViewDelegate

extension DFTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.txt = textView.text
        viewModel.attributedTxt = textView.attributedText
        
        let captureSize = textView.sizeThatFits(CGSize(
            width: textView.bounds.width,
            height: .greatestFiniteMagnitude
        ))
        viewModel.captureSize = captureSize
    }
}

// MARK: - VerticalSlider

final class VerticalSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        transform = CGAffineTransform(rotationAngle: -.pi / 2)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        transform = CGAffineTransform(rotationAngle: -.pi / 2)
    }
}
