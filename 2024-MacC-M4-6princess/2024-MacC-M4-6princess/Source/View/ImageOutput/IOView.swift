//
//  IOView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//

import SwiftUI
import Photos
import FirebaseCore
import FirebaseStorage

// 이미지 편집 메인 화면
struct IOView: View {
    var bg:UIImage
    var idol:UIImage
    //    @StateObject var viewModel = IEViewModel()
    @StateObject var viewModel = IOViewModel()
    @GestureState var pinchState = 1.0 // 핀치 제스쳐를 위한 State 변수
    @State var isAnimating = false
    @State var isSave = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
                    viewModel.saveRenderedView(content: canvasView)
                    viewModel.saveAnimate = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isSave = true
                    }
                    print("canvasView onAppear")
                    Task {
                        if let compositeImage = viewModel.compositeImage {
                            do {
                                let result = try await StorageManager.shared.uploadImage(image: compositeImage)
                                print("Image uploaded successfully! Path: \(result.path), Name: \(result.name)")
                            } catch {
                                print("Image upload failed with error: \(error.localizedDescription)")
                            }
                        } else {
                            print("No image to upload.")
                        }
                    }


//                    if let compositeImage = viewModel.compositeImage{
//                        let image = UIImage(named: "exampleImage")! // 테스트용 이미지
//                           do {
//                               let result = try await
//                               print("Image uploaded successfully!")
//                               print("Path: \(result.path), Name: \(result.name)")
//                           } catch {
//                               print("Image upload failed: \(error.localizedDescription)")
//                           }
//                    }
                    
                }
            
            VStack{
                //                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                Text("저장된 사진은 갤러리에서 확인해주세요.")
                    .font(.system(size:12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray01)
                    .padding()
                //                }
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width:.infinity,height: 60)
                        .background(Color.pointPink)
                        .cornerRadius(10)
                        .overlay(
                            Text("카메라로 이동")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        )
                }
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width:.infinity,height: 60)
                        .background(Color.pointPink)
                        .cornerRadius(10)
                        .overlay(
                            Text("QR 생성")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        )
                }
            }
            //            .frame(height: (UIScreen.main.bounds.height-(UIScreen.main.bounds.width*4/3))/2)
            Spacer()
            
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
            viewModel.canvasOnAppear(bgImg: bg, idolImg: idol, bounds: UIScreen.main.bounds.size)
            
            
            print("body onAppear")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류 발생"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        // 상단 툴바
        .navigationBarBackButtonHidden()
    }
    var canvasView: some View {
        IOCanvasView(viewModel: viewModel)
    }
}
