//
//  QRCodeSheetView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 2/12/25.
//

import SwiftUI
import FirebaseAnalytics

struct QRCodeSheetView: View {
    let qrCodeImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if let qrCodeImage = qrCodeImage {
                // QR 코드 이미지 표시
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()
            } else {
                // QR 코드 로딩 중일 때 ProgressView 표시
                ProgressView("QR 코드를 생성 중입니다...")
                    .padding()
            }
            
            Button("닫기") {
                dismiss()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.pointPink)
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            Analytics.logEvent("A99_QR보기", parameters: nil) // 라벨링 추가
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
                    IOShareSheet(isPresented: $isShowingShareSheet, shareData: (image, "title", "Frameet으로 사진 낄여왔음"))
                }
            }
        }
        .overlay(
            Group{
                if let image = image {
                    IOShareSheet(isPresented: $isShowingShareSheet, shareData: (image, "title", "Frameet으로 사진 낄여왔음"))
                }
            }
        )
    }
    
}
