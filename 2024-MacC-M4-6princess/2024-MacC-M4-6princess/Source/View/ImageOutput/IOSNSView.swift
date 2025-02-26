//
//  IOSNSView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 2/12/25.
//
import SwiftUI

struct IOSNSView: View {
    @StateObject var viewModel: IOViewModel
    @State private var showingActivitySheet = false
    
    var body: some View {
        HStack(spacing: 20) {
            // Instagram 공유 버튼
            Button("insta") {
                if InstagramSharingUtils.canOpenInstagramStories, let composite = viewModel.compositeImage {
                    InstagramSharingUtils.shareToInstagramStories(composite)
                }
            }
            .buttonStyle(.bordered)
            
            // X 공유 버튼
            Button("X") {
                guard let composite = viewModel.compositeImage else {
                    print("이미지가 없습니다.")
                    return
                }
                
                XSharingUtils.shareToXWithImage(
                    text: "이 멋진 사진은 frameet으로부터 만들어졌어요! 🍀",
                    image: composite
                )
            }
            .buttonStyle(.borderless)
            
            // 더보기 버튼
            Button(action: {
                showingActivitySheet = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
            }
            .buttonStyle(.borderless)
        }
        .sheet(isPresented: $showingActivitySheet) {
            if let composite = viewModel.compositeImage {
                ActivityViewController(
                    activityItems: [
                        "이 멋진 사진은 frameet으로부터 만들어졌어요! 🍀",
                        composite
                    ],
                    applicationActivities: nil
                )
            }
        }
    }
}

// UIActivityViewController를 위한 래퍼
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
