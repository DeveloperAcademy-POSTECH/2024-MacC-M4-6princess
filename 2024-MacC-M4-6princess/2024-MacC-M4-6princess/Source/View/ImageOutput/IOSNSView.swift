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





final class SharePinNumberActivityItemSource: NSObject, UIActivityItemSource {
    private var title: String
    private var content: String
    private var image: UIImage
    
    init(title: String, content: String, photo: UIImage) {
        self.title = title
        self.content = content
        self.image = photo
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content
    }
    //타임아웃이였나..크기문제인가...ㅠ
//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        // PNG 데이터로 변환
//        if let pngData = image.pngData() {
//            if activityType == .airDrop {
//                return pngData
//            }
//            
//            // 트위터 업로드를 위한 이미지 크기 조정
//            let maxWidth: CGFloat = 4096
//            let maxHeight: CGFloat = 4096
//            
//            // 현재 이미지 크기
//            let imageSize = image.size
//            
//            // 비율 계산
//            let aspectRatio = imageSize.width / imageSize.height
//            
//            var newWidth: CGFloat = imageSize.width
//            var newHeight: CGFloat = imageSize.height
//            
//            // 비율을 유지하면서 크기 조정
//            if imageSize.width > maxWidth || imageSize.height > maxHeight {
//                if imageSize.width > imageSize.height {
//                    newWidth = maxWidth
//                    newHeight = newWidth / aspectRatio
//                } else {
//                    newHeight = maxHeight
//                    newWidth = newHeight * aspectRatio
//                }
//            }
//            
//            // 리사이즈된 이미지 생성
//            let newSize = CGSize(width: newWidth, height: newHeight)
//            UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
//            image.draw(in: CGRect(origin: .zero, size: newSize))
//            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            // 리사이즈된 이미지를 PNG로 변환
//            if let resizedImageData = resizedImage?.pngData() {
//                return resizedImageData
//            }
//        }
//        
//        return content
//    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // PNG 데이터로 변환
        if let pngData = image.pngData() {
            if activityType == .airDrop {
                return pngData
            }

            // 트위터 업로드를 위한 이미지 크기 조정
            let maxWidth: CGFloat = 4096
            let maxHeight: CGFloat = 4096
            
            // 인스타그램 업로드를 위한 크기 제한
            let instagramMaxWidth: CGFloat = 1080
            let instagramMaxHeight: CGFloat = 1080
            
            // 현재 이미지 크기
            let imageSize = image.size
            
            // 비율 계산
            let aspectRatio = imageSize.width / imageSize.height
            
            var newWidth: CGFloat = imageSize.width
            var newHeight: CGFloat = imageSize.height
            
            // 비율을 유지하면서 크기 조정
            if imageSize.width > instagramMaxWidth || imageSize.height > instagramMaxHeight {
                if imageSize.width > imageSize.height {
                    newWidth = instagramMaxWidth
                    newHeight = newWidth / aspectRatio
                } else {
                    newHeight = instagramMaxHeight
                    newWidth = newHeight * aspectRatio
                }
            }

            // 리사이즈된 이미지 생성
            let newSize = CGSize(width: newWidth, height: newHeight)
            UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // 리사이즈된 이미지를 PNG로 변환
            if let resizedImageData = resizedImage?.pngData() {
                if resizedImageData.count <= 30_000_000 {  // 30MB 이하
                    return resizedImageData
                } else {
                    print("Image size exceeds 30MB, resizing further might be required.")
                }
            }
        }
        
        return content
    }

//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        // PNG 데이터로 변환
//        // 카카오톡 & 트위터는 15MB 이하의 JPEG 변환 (압축율 조정)
//        //        if activityType == .postToTwitter {
//        //
//        //            var compressionQuality: CGFloat = 0.4
//        //            var jpegData: Data? = image.jpegData(compressionQuality: compressionQuality)
//        //            if let data = jpegData {
//        //                let sizeInMB = Double(data.count) / 1_048_576 // 바이트를 MB로 변환
//        //                print("JPEG 생성 성공: \(String(format: "%.2f", sizeInMB))MB")
//        //            } else {
//        //                print("JPEG 생성 실패")
//        //            }
//        //            while let data = jpegData, data.count > 5_242_880, compressionQuality > 0.1 {
//        //                compressionQuality -= 0.2
//        //                jpegData = image.jpegData(compressionQuality: compressionQuality)
//        //            }
//        //
//        //            return image
//        //
//        //        }
//        if activityType != .airDrop{
//            if let jpegData = image.jpegData(compressionQuality: 0.4){
//                return jpegData
//            }
//        }
//        if
//            //            activityType == .postToWeibo ||
//            activityType == UIActivity.ActivityType(rawValue: "com.kakao.talk.share")
//    
//        {
//               var compressionQuality: CGFloat = 0.7
//               var jpegData: Data? = image.jpegData(compressionQuality: compressionQuality)
//
//               while let data = jpegData, data.count > 15_728_640, compressionQuality > 0.1 {
//                   compressionQuality -= 0.1
//                   jpegData = image.jpegData(compressionQuality: compressionQuality)
//               }
//
//               return jpegData
//           }
////        if let pngData = image.pngData() {
////            if activityType == .airDrop || activityType == .postToTwitter{
////                return pngData
////            }
////            return pngData
////        }
//        
//
//        return content
//    }
//    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = content
        metaData.iconProvider = NSItemProvider(object: image)
        metaData.originalURL = URL(string: "https://apps.apple.com/kr/app/frameet-%ED%94%84%EB%A0%88%EC%9E%84%EB%B0%8B-%EC%B5%9C%EC%95%A0%EC%99%80-%ED%95%A8%EA%BB%98-%ED%8A%B9%EB%B3%84%ED%95%9C-%EC%9D%BC%EC%83%81/id6737822930")
        return metaData
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
