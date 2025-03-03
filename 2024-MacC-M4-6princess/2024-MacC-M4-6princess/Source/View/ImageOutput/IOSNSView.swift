import SwiftUI
import UIKit
import LinkPresentation


struct IOSNSView: View {
    @StateObject var viewModel: IOViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Instagram 공유 버튼
            Button("insta") {
                if InstagramSharingUtils.canOpenInstagramStories, let composite = viewModel.compositeImage {
                    InstagramSharingUtils.shareToInstagramStories(composite)
                }
            }
            .buttonStyle(.bordered)
            
            // 더보기 버튼 (Share with UIActivityViewController)
            Button(action: {
                viewModel.showAcitivity.toggle()
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
            }
            .buttonStyle(.borderless)
        }
        
    }
}






struct SnsTestView: View {
    @State private var isShowingBottomSheet = false
    @State private var isShowingShareSheet = false
    //    @State private var selectedPlatform: String? = nil
    @State var image: UIImage? = UIImage(named: "testFrame")
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the image
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            // Share button
            Button("공유하기") {
                isShowingBottomSheet = true
                isShowingShareSheet = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $isShowingBottomSheet) {
            Group{
                if let image = image {
                    ShareSheet(isPresented: $isShowingShareSheet, shareData: (image, "title", "Frameet으로 사진 낄여왔음"))
                }
            }
        }
        .overlay(
            Group{
                if let image = image {
                    ShareSheet(isPresented: $isShowingShareSheet, shareData: (image, "title", "Frameet으로 사진 낄여왔음"))
                }
            }
        )
      }
    
}

// 바텀시트 뷰 (공유 플랫폼 선택)
struct BottomSheetView: View {
//    let shareAction: (String) -> Void
    var viewModel : IOViewModel
    var body: some View {
        VStack {
            Spacer()
           
            HStack(spacing: 20) {
                ShareButton(icon: "x.icon", text: "트위터"
                            , action: { viewModel.ShowShare = false
                    print("showshare:\(viewModel.ShowShare)")
                    viewModel.showAcitivity.toggle()
                    print("showActivity:\(viewModel.showAcitivity)")
                }
                )
                ShareButton(icon: "insta.icon", text: "인스타"
                            , action: { if InstagramSharingUtils.canOpenInstagramStories, let composite = viewModel.compositeImage {
                                InstagramSharingUtils.shareToInstagramStories(composite)
                            } }
                )
                ShareButton(icon: "kakao.icon", text: "카카오톡"
                            , action: { viewModel.showAcitivity.toggle() }
                )
                ShareButton(icon: "message.icon", text: "메시지"
                            , action: {
                    viewModel.showAcitivity.toggle()
                }
                )
                ShareButton(icon: "more.icon", text: "더보기"
                            , action: { viewModel.showAcitivity.toggle() }
                )
            }
            .padding(.vertical)
            Spacer()
        }
        .padding()
    }
}
// 공유 버튼 스타일
struct ShareButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Image(icon)
                    .font(.largeTitle)
                   
                    .padding(.bottom,5)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.gray01)
            }
        }
    }
}
import UIKit

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
            self.viewModel.ShowShare = false
            print("showshare: \(self.viewModel.ShowShare)")
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
