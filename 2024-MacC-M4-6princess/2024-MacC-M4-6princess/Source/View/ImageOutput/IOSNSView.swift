import SwiftUI

struct IOSNSView: View {
    @StateObject var viewModel: IOViewModel
    @State private var isShowingShareSheet = false
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
                viewModel.isShowShareSheet = false
                isShowingShareSheet = true
                //                // If we have an image to share
                //                if let image = viewModel.compositeImage {
                //                    // Create share action
                //                    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                //
                //                    // Present the view controller
                //                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                //                       let rootViewController = windowScene.windows.first?.rootViewController {
                //                        rootViewController.present(activityVC, animated: true)
                //                    }
                //                }
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
            }
            .buttonStyle(.borderless)
        }
        .background(
            Group{
                if let image = viewModel.compositeImage{
                    ShareSheet(isPresented: $isShowingShareSheet, shareData: (image,"title","Frameet으로 사진 낋여왔음"))
                }
            }
        )
//        .sheet(isPresented: $isShowingShareSheet){
//            Group{
//                if let image = viewModel.compositeImage{
//                    ShareSheet(isPresented: $isShowingShareSheet, shareData: (image,"title","Frameet으로 사진 낋여왔음"))
//                }
//            }
//        }
    }
}
import SwiftUI
import UIKit
import LinkPresentation

struct SnsTestView: View {
    @State private var isShowingShareSheet = false
    @State var imageName = "testFrame"
    @State var image: UIImage? = UIImage(named: "testFrame")
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the image
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            // Share button
            Button("공유하기") {
                isShowingShareSheet = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Prepare any resources if needed
        }
        .background(
            Group{
                if let image = image{
                    ShareSheet(isPresented: $isShowingShareSheet, shareData: (image,"title","Frameet으로 사진 낋여왔음"))
                }
            }
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var shareData: (imageName: UIImage, title: String, content: String)
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            
            
            
            let items = [
                SharePinNumberActivityItemSource(
                    title: shareData.title,
                    content: shareData.content,
                    image: shareData.imageName
                ),
                shareData.imageName // 이미지도 추가
            ]
            
            
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            // Closure to handle dismissal
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                self.isPresented = false
            }
            
            // Present the activity view controller
            uiViewController.present(activityVC, animated: true)
        }
    }
}
final class SharePinNumberActivityItemSource: NSObject, UIActivityItemSource {
    private var title: String
    private var content: String
    private var image: UIImage
    private lazy var pngData: Data? = {
        return image.pngData()
    }()
    
    init(title: String, content: String, image: UIImage) {
        self.title = title
        self.content = content
        self.image = image
        
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return pngData ?? image  // 기본적으로 이미지를 플레이스홀더로 사용
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        //        // 이미지를 지원하는 모든 서비스에서는 PNG 데이터 반환
        //        if activityType == .saveToCameraRoll ||
        //           activityType == .postToFacebook ||
        //           activityType == .postToTwitter ||
        //           activityType == .postToWeibo ||
        //           activityType == .postToTencentWeibo ||
        //           activityType == .postToFlickr ||
        //           activityType == .postToVimeo ||
        //           activityType == .addToReadingList ||
        //           activityType == .assignToContact ||
        //           activityType == .copyToPasteboard {
        //            return pngData ?? image  // PNG 데이터 반환 (변환 실패 시 이미지 자체 반환)
        ////        }
        //
        //        // 텍스트 메시지 또는 이메일과 같은 서비스는 텍스트와 이미지 모두 공유 가능
        //        if activityType == .message ||
        //           activityType == .mail ||
        //           activityType == .airDrop {
        //            // 이미지는 별도로 ActivityViewController의 activityItems 배열에 포함됨
        //            return content  // 텍스트 내용 제공
        //        }
        
        // 그 외 서비스는 기본적으로 PNG 데이터 반환
        return content
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return title
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = title
        metaData.iconProvider = NSItemProvider(object: image)
        
        // 빈 문자열이 아닌 경우에만 URL 설정
        if !content.isEmpty {
            metaData.originalURL = URL(fileURLWithPath: content)
        }
        
        return metaData
    }
}
