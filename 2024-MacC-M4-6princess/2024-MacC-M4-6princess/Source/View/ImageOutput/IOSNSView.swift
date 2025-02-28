import SwiftUI
import UIKit
import LinkPresentation


struct IOSNSView: View {
    @StateObject var viewModel: IOViewModel
//    @State private var isShowingShareSheet = false
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
//                viewModel.isShowShareSheet = false
//                isShowingShareSheet = true
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

// 공유 데이터 핸들러
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
        return image
    }
    
//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        return image
//    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // For messaging apps, you might need both text and image
        if activityType == .airDrop{
            return image
        }
        return [image, content]
    }
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return content
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = content
        metaData.iconProvider = NSItemProvider(object: image)
        metaData.originalURL = URL(string: "https://apps.apple.com/kr/app/frameet-%ED%94%84%EB%A0%88%EC%9E%84%EB%B0%8B-%EC%B5%9C%EC%95%A0%EC%99%80-%ED%95%A8%EA%BB%98-%ED%8A%B9%EB%B3%84%ED%95%9C-%EC%9D%BC%EC%83%81/id6737822930") // URL 추가
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
//                if Bool.random() {
//                    isShowingBottomSheet = true
//                } else {
//                    isShowingShareSheet = true
//                }
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
//            BottomSheetView { platform in
//                isShowingBottomSheet = false // 바텀시트 닫기
//                //                selectedPlatform = platform
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
//                    
//                    isShowingShareSheet = true
//                    
//                }
//            }
//            .presentationDetents([.fraction(0.3)])
        }
        .overlay(
            Group{
                if let image = image {
                    ShareSheet(isPresented: $isShowingShareSheet, shareData: (image, "title", "Frameet으로 사진 낄여왔음"))
                }
            }
        )
        //        .sheet(isPresented: $isShowingShareSheet) {
        //            if let image = image {
        //                ShareSheet(isPresented: $isShowingShareSheet, shareData: (image, "title", "Frameet으로 사진 낄여왔음"))
        //            }
        //        }
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
