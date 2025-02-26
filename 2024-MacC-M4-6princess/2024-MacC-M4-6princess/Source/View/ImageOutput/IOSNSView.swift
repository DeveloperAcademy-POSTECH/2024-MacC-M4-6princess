import SwiftUI

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
                // If we have an image to share
                if let image = viewModel.compositeImage {
                    // Create share action
                    let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    
                    // Present the view controller
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(activityVC, animated: true)
                    }
                }
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
            }
            .buttonStyle(.borderless)
        }
    }
}
import SwiftUI
import UIKit
import LinkPresentation

struct SnsTestView: View {
    @State private var isShowingShareSheet = false
    @State var imageName = "testFrame"
    
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
            ShareSheet(isPresented: $isShowingShareSheet, shareData: (imageName,"title","content"))
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var shareData: (imageName: String, title: String, content: String)
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let image = UIImage(named: shareData.imageName) ?? UIImage()
            
//            let items = [SharePinNumberActivityItemSource(
//                title: shareData.title,
//                content: shareData.content,
//                image: image
//            )]
            let items = [
                SharePinNumberActivityItemSource(
                    title: shareData.title,
                    content: shareData.content,
                    image: image
                ),
                image // 이미지도 추가
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

// The SharePinNumberActivityItemSource class you provided
final class SharePinNumberActivityItemSource: NSObject, UIActivityItemSource {
    private var title: String
    private var content: String
    private var image: UIImage
    
    init(title: String, content: String, image: UIImage) {
        self.title = title
        self.content = content
        self.image = image
        
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        if activityType == .saveToCameraRoll || activityType == .postToFacebook || activityType == .postToTwitter {
            return image  // 이미지만 공유할 때
        }
        return content  // 기본적으로 텍스트를 공유
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
        metaData.originalURL = URL(fileURLWithPath: content)
        return metaData
    }
}
