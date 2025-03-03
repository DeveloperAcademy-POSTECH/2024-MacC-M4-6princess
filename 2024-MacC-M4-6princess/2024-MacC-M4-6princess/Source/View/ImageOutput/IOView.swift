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
    let motionManager: MotionManager
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = IOViewModel()
    
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                    HStack(alignment: .center, spacing: 14) {
                        Text("저장완료")
                            .font(.system(size:17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                    }
                    .padding(.top, 26)
                }
                else{
                    HStack(alignment: .center, spacing: 14) {
                        Text("저장완료")
                            .font(.system(size:17))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                    }
                    .padding(.top, 26)
                }
                
                // 후보정 레이어 편집 뷰
                canvasView
                
                    .onAppear{
                        viewModel.saveRenderedView(content: canvasView, motionManager: motionManager) // 사진을 그리면서 동시에 저장
                        viewModel.saveAnimate = true
                        print("canvasView onAppear")
                    }
                    .applyIf(motionManager.currentOrientation != .portrait && motionManager.currentOrientation != .portraitUpsideDown) { original in
                        original.modifier(
                            RotatedAndScaledEffect(
                                angle: motionManager.rotationAngleCanvasView(for: motionManager.currentOrientation),
                                scale: 0.75  //하드코딩 수정필요
                            )
                        )
                    }
                    .scaledToFit()
                Spacer()
                
                if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0{
                    VStack(alignment: .center, spacing: 8){
                        Text("저장된 사진은 갤러리에서 확인해주세요.")
                            .font(.system(size:12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                        HStack{
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
                            Button(action: {
                                
                                viewModel.ShowShare.toggle()
                                //                                viewModel.showAcitivity.toggle()
                            }) {
                                Image("share.icon")
                                    .resizable()
                                    .frame(width:60,height: 60)
                                   
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .frame(height: 60)
//                                    .background(Color.pointPink)
//                                    .cornerRadius(10)
//                                    .overlay(
//                                        Text("SNS 공유")
//                                            .foregroundColor(.white)
//                                            .font(.system(size: 18, weight: .bold))
//                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 26)
                        .padding(.horizontal, 20)
                        
                    }
                }
                else{
                    VStack(alignment: .center, spacing: 8){
                        Text("저장된 사진은 갤러리에서 확인해주세요.")
                            .font(.system(size:12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray01)
                            .padding(5)
                        HStack{
                            // 카메라로 이동 버튼
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 40)
                                    .background(Color.pointPink)
                                    .cornerRadius(10)
//                                    .padding(.trailing)
                                    .overlay(
                                        Text("카메라로 이동")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                    )
                            }
                            Button(action: {
                                viewModel.ShowShare = true
                                //                                viewModel.showAcitivity.toggle()
                            }
                            ) {
                                Image("share.icon")
                                    .resizable()
                                    .frame(width:40,height: 40)
                                    
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .frame(height: 40)
//                                    .background(Color.pointPink)
//                                    .cornerRadius(10)
//                                    .overlay(
//                                        Text("SNS 공유")
//                                            .foregroundColor(.white)
//                                            .font(.system(size: 18, weight: .bold))
//                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 26)
                        .padding(.horizontal, 20)
                        
                    }
                }
            }
            
        }
        .onAppear{
            viewModel.bgImg = bg
            viewModel.idolImg = idol
            viewModel.canvasOnAppear(bgImg: bg, idolImg: idol, bounds: UIScreen.main.bounds.size)
            Analytics.logEvent("A6_사진저장", parameters: nil)
            
            print("body onAppear")
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("오류 발생"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
        }
        .sheet(isPresented: $viewModel.ShowShare) {
            BottomSheetViewWrapper(viewModel: viewModel)
                .presentationDetents([.height(150)])
        }
        .onChange(of: viewModel.ShowShare, perform: { newValue in
            if viewModel.ShowShare == false && viewModel.showAcitivity == true{
                print("onchange start")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    if let _ = viewModel.compositeImage {
                        viewModel.changeOverlay = true
                        print("changeoverlay")
                    }
                }
            }
        })
//        .onChange(of: viewModel.ShowShare) { newValue in
//            if !newValue {
//                DispatchQueue.main.async {
//                    if let _ = viewModel.compositeImage {
//                        viewModel.showAcitivity = true
//                    }
//                }
//            }
//        }

//        .background(
//            if viewModel.ShowShare{
//                BottomSheetViewWrapper(viewModel: viewModel)
////                    .frame(height:150)
//            }
//            else if viewModel.showAcitivity{
//                Group{
//                    if let photo = viewModel.compositeImage
//                        ,viewModel.showAcitivity
//                    {
//                        ShareSheet(isPresented: $viewModel.showAcitivity, shareData: (photo,"title","Frameet으로 사진 낋여왔음"))
//                    }
//                    
//                }
//            }
//           
//        )
        .overlay(
        Group {
//            if viewModel.ShowShare {
//                BottomSheetViewWrapper(viewModel: viewModel)
//                    .onDisappear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                            if viewModel.showAcitivity{
//                                viewModel.changeOverlay = true
//                            }
//                        }
//                    }
//            }
//            else
            if viewModel.changeOverlay, let photo = viewModel.compositeImage {
                ShareSheet(isPresented: $viewModel.changeOverlay, shareData: (photo, "title", "Frameet으로 사진 찍어왔음"))
                    .onAppear{
                        print("sharesheet start")
                    }
            }
        }
    )

        
        // 상단 툴바
        .navigationBarBackButtonHidden()
    }
    var canvasView: some View {
        IOCanvasView(viewModel: viewModel)
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


//        .sheet(isPresented: $viewModel.showAcitivity){
////            BottomSheetView()
////                .presentationDetents([.height(300)])
////            IOSNSView(viewModel: viewModel)
////                .presentationDetents([.height(300)])
//            Group{
//                if let photo = viewModel.compositeImage
//                {
//                    ShareSheet(isPresented: $viewModel.showAcitivity, shareData: (photo,"title","Frameet으로 사진 낋여왔음"))
//                        .presentationDetents([.height(300)])
//                }
//            }
//        }
import SwiftUI

struct BottomSheetViewWrapper: UIViewControllerRepresentable {
    var viewModel: IOViewModel

    func makeUIViewController(context: Context) -> BottomSheetViewController {
        return BottomSheetViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: BottomSheetViewController, context: Context) {}
}
