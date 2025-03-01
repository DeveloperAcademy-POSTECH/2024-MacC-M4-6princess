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


// 공유 버튼 스타일
struct ShareButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text(text)
                    .font(.caption)
            }
        }
    }
}
struct ShareSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var shareData: (image: UIImage, title: String, content: String)
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let items: [Any] = [
                SharePinNumberActivityItemSource(title: shareData.title, content: shareData.content, photo: shareData.image)
            ]
            
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            }
            uiViewController.present(activityVC, animated: true, completion: nil)
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
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // PNG 데이터로 변환
        if let pngData = image.pngData() {
            if activityType == .airDrop {
                return pngData
            }
            
            // 트위터 업로드를 위한 이미지 크기 조정
            let maxWidth: CGFloat = 4096
            let maxHeight: CGFloat = 4096
            
            // 현재 이미지 크기
            let imageSize = image.size
            
            // 비율 계산
            let aspectRatio = imageSize.width / imageSize.height
            
            var newWidth: CGFloat = imageSize.width
            var newHeight: CGFloat = imageSize.height
            
            // 비율을 유지하면서 크기 조정
            if imageSize.width > maxWidth || imageSize.height > maxHeight {
                if imageSize.width > imageSize.height {
                    newWidth = maxWidth
                    newHeight = newWidth / aspectRatio
                } else {
                    newHeight = maxHeight
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
                return resizedImageData
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
    let shareAction: (String) -> Void
    
    var body: some View {
        VStack {
            Text("공유할 플랫폼 선택")
                .font(.headline)
                .padding(.top)
            
            HStack(spacing: 20) {
                ShareButton(icon: "bird.fill", text: "트위터", action: { shareAction("twitter") })
                ShareButton(icon: "camera.fill", text: "인스타", action: { shareAction("instagram") })
                ShareButton(icon: "bubble.left.fill", text: "카카오톡", action: { shareAction("kakaotalk") })
                ShareButton(icon: "message.fill", text: "메시지", action: { shareAction("message") })
            }
            .padding(.vertical)
        }
        .padding()
    }
}
