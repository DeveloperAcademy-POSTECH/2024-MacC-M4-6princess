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
                // 텍스트만 공유하는 경우
                XSharingUtils.shareToX(text: "이 멋진 사진은 frameet으로부터 만들어져서...🍀") { success in
                    if !success {
                        print("X 앱을 열 수 없습니다")
                    }
                }
                
                // 이미지와 텍스트 함께 공유하는 경우
                if let composite = viewModel.compositeImage {
                    XSharingUtils.shareToXWithImage(
                        text: "공유하고 싶은 메시지",
                        image: composite
                    )
                }
            }
            .buttonStyle(.borderless)
        }
    }
    
}

