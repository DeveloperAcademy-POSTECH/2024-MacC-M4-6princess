//
//  IOView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//

import SwiftUI
import Photos
import FirebaseAnalytics

// 이미지 편집 메인 화면
struct IOView: View {
    var bg:UIImage
    var idol:UIImage
    @StateObject var viewModel = IOViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isAnimating = false
    @State var isSave = false
    @State private var isUploading = false
    
    @State private var qrCodeImage: UIImage? = nil
    @State private var uploadError: String? = nil
    @State var showQRSheet = false
    @State private var uploadedImagePath: String? = nil // 업로드된 이미지의 경로
    let motionManager: MotionManager
    
    var body: some View {
        VStack{
            if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                Spacer()
            }
            HStack(alignment: .center, spacing: 14) {
                Text("저장완료")
                    .font(.system(size:17))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray01)
            }
            .padding(.vertical)
            // 후보정 레이어 편집 뷰
            canvasView
                .onAppear{
                    isAnimating = true
                    viewModel.saveRenderedView(content: canvasView, motionManager: motionManager)
                    viewModel.saveAnimate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isSave = true
                    }
                    print("canvasView onAppear")
                    uploadImage()
                }
            
            VStack{
                Text("저장된 사진은 갤러리에서 확인해주세요.")
                    .font(.system(size:12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray01)
                    .padding()
                HStack(spacing: 16) {
                    
//                    Button(action: {
//                        showQRSheet = true
//                    }) {
//                        RoundedRectangle(cornerRadius: 10) // RoundedRectangle을 사용
//                            .stroke(Color.pointPink, lineWidth: 1) // 테두리 추가
//                            .background(
//                                RoundedRectangle(cornerRadius: 10) // 동일한 모서리 반경의 배경
//                                    .foregroundColor(.white)
//                            )
//                            .frame(height: 60) // 높이 설정
//                            .overlay(
//                                Text("QR 보기")
//                                    .foregroundColor(.pointPink)
//                                    .font(.system(size: 18, weight: .bold))
//                            )
//                    }

                    // 카메라로 이동 버튼
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 60)
                            .background(Color.pointPink)
                            .cornerRadius(10)
                            .overlay(
                                Text("카메라로 이동")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .bold))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

            }
            Spacer()
            
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
            viewModel.canvasOnAppear(bgImg: bg, idolImg: idol, bounds: UIScreen.main.bounds.size)
            Analytics.logEvent("A6_사진저장", parameters: nil)
            
            print("body onAppear")
        }
//        .onDisappear {
//            // QR 보기를 안눌렀으면 파이어베이스에서 사진 삭제
//                   deleteUploadedImageIfNeeded()
//               }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류 발생"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        
        // 상단 툴바
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showQRSheet) {
                    QRCodeSheetView(qrCodeImage: qrCodeImage)
                }
    }
    var canvasView: some View {
        IOCanvasView(viewModel: viewModel)
    }
    private func uploadImage() {
        guard let selectedImage = viewModel.compositeImage else { return }
            isUploading = true
            StorageManager.shared.uploadImage(image: selectedImage) { result in
                DispatchQueue.main.async {
                    isUploading = false
                    switch result {
                    case .success(let url):
                        self.qrCodeImage = QRCodeGenerator.shared.generateQRCode(from: url.absoluteString)
                            self.uploadedImagePath = url.path // 업로드된 이미지 경로 저장
                    case .failure(let error):
                        self.uploadError = error.localizedDescription
                    }
                }
            }
        }
    private func deleteUploadedImageIfNeeded() {
         guard let path = uploadedImagePath else { return }
         StorageManager.shared.deleteImage(path: path) { result in
             switch result {
             case .success:
                 print("Image successfully deleted from Firebase.")
             case .failure(let error):
                 print("Failed to delete image: \(error.localizedDescription)")
             }
         }
     }
}



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
