//
//  BottomSheetViewController.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 3/5/25.
//

import SwiftUI
import UIKit
import LinkPresentation

struct BottomSheetViewWrapper: UIViewControllerRepresentable {
    var viewModel: IOViewModel
    
    func makeUIViewController(context: Context) -> BottomSheetViewController {
        return BottomSheetViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: BottomSheetViewController, context: Context) {}
}
class BottomSheetViewController: UIViewController {
    var viewModel: IOViewModel
    
    init(viewModel: IOViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        let twitterButton = createShareButton(icon: "x.icon", text: "트위터") { [weak self] in
            guard let self = self else { return }
            self.viewModel.showShareButton = false
            print("showshare: \(self.viewModel.showShareButton)")
            self.viewModel.showAcitivity.toggle()
            print("showActivity: \(self.viewModel.showAcitivity)")
        }
        
        let instagramButton = createShareButton(icon: "insta.icon", text: "인스타") { [weak self] in
            guard let self = self, let composite = self.viewModel.compositeImage else { return }
            if InstagramSharingUtils.canOpenInstagramStories {
                InstagramSharingUtils.shareToInstagramStories(composite)
            }
        }
        
        let kakaoButton = createShareButton(icon: "kakao.icon", text: "카카오톡") { [weak self] in
            self?.viewModel.showAcitivity.toggle()
        }
        
        let messageButton = createShareButton(icon: "message.icon", text: "메시지") { [weak self] in
            self?.viewModel.showAcitivity.toggle()
        }
        
        let moreButton = createShareButton(icon: "more.icon", text: "더보기") { [weak self] in
            self?.viewModel.showAcitivity.toggle()
        }
        
        [twitterButton, instagramButton, kakaoButton, messageButton, moreButton].forEach { stackView.addArrangedSubview($0) }
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createShareButton(icon: String, text: String, action: @escaping () -> Void) -> UIStackView {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: icon)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        
        return stackView
    }
}
