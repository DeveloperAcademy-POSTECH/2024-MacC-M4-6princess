//
//  IOSNSView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 2/12/25.
//
import SwiftUI

struct IOSNSView: View {
    @StateObject var viewModel: IOViewModel
    
    var body: some View {
        //여기에 들어가는 시트는 인스타, 트위터(X) 텍스트로 되어있는 버튼 각각
        HStack(spacing: 20) {
            // Instagram 공유 버튼
            Button("insta") {
                if InstagramSharingUtils.canOpenInstagramStories, let composite = viewModel.compositeImage {
                    InstagramSharingUtils.shareToInstagramStories(composite)
                }
            }
            .buttonStyle(.bordered)

            // X (구 Twitter) 공유 버튼
            Button("X") {
                if let composite = viewModel.compositeImage {
                    shareToX(image: composite)
                }
            }
            .buttonStyle(.borderless)
        }
    }

    // MARK: - X (구 Twitter) 공유 기능 추가
    private func shareToX(image: UIImage) {
        guard let imageData = image.pngData() else {
            print("❌ 이미지 변환 실패")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        
        // 현재 화면의 최상위 UIViewController를 찾아서 공유 시트 표시
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true, completion: nil)
        }
    }
}
