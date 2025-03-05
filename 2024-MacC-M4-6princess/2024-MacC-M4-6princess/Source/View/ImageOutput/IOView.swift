//
//  IOView.swift
//  2024-MacC-M4-6princess
//
//  Created by ram on 11/27/24.
//

import SwiftUI
import Photos
import FirebaseAnalytics
import UIKit
import LinkPresentation
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

import UIKit
import LinkPresentation

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

final class SharePinNumberActivityItemSource: NSObject, UIActivityItemSource {
    private var title: String
    private var content: String
    private var image: UIImage
    
    init(title: String, content: String, photo: UIImage) {
        self.title = title
        self.content = content
        self.image = photo
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // PNG 데이터로 변환
        guard let pngData = image.pngData() else { return content }
        //        
        //        if activityType == .airDrop {
        //            return pngData
        //        }
        //        
        //        // 최대 크기 설정 (Twitter: 4096x4096, Instagram: 1080x1080)
        //        let maxSize: CGFloat = 4096
        //        let instagramMaxSize: CGFloat = 1080
        //        let imageSize = image.size
        //        let aspectRatio = imageSize.width / imageSize.height
        //        
        //        var newWidth = imageSize.width
        //        var newHeight = imageSize.height
        //        
        //        // Twitter 크기 제한 적용
        //        if imageSize.width > maxSize || imageSize.height > maxSize {
        //            if imageSize.width > imageSize.height {
        //                newWidth = maxSize
        //                newHeight = newWidth / aspectRatio
        //            } else {
        //                
        //                newHeight = maxSize
        //                newWidth = newHeight * aspectRatio
        //            }
        //        }
        //        
        //        // Instagram 크기 제한 적용 (더 엄격한 조건)
        //        if newWidth > instagramMaxSize || newHeight > instagramMaxSize {
        //            if newWidth > newHeight {
        //                newWidth = instagramMaxSize
        //                newHeight = newWidth / aspectRatio
        //            } else {
        //                newHeight = instagramMaxSize
        //                newWidth = newHeight * aspectRatio
        //            }
        //        }
        //        
        //        // 리사이즈된 이미지 생성
        //        let newSize = CGSize(width: newWidth, height: newHeight)
        //        UIGraphicsBeginImageContextWithOptions(newSize, true, image.scale) // opaque를 true로 설정
        //        image.draw(in: CGRect(origin: .zero, size: newSize))
        //        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        //        UIGraphicsEndImageContext()
        //        
        //        // 리사이즈된 이미지를 PNG로 변환 및 크기 확인
        //        if let resizedImageData = resizedImage?.pngData() {
        //            if resizedImageData.count <= 30_000_000 { // 30MB 이하
        //                return resizedImageData
        //            } else {
        //                print("Image size exceeds 30MB, resizing further might be required.")
        //                // 추가 압축 또는 크기 조정 로직을 여기에 구현 가능
        //            }
        //        }
        //        
        //        return content
        return pngData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metaData = LPLinkMetadata()
        metaData.title = content
        metaData.iconProvider = NSItemProvider(object: image)
        metaData.originalURL = URL(string: "https://apps.apple.com/kr/app/frameet-%ED%94%84%EB%A0%88%EC%9E%84%EB%B0%8B-%EC%B5%9C%EC%95%A0%EC%99%80-%ED%95%A8%EA%BB%98-%ED%8A%B9%EB%B3%84%ED%95%9C-%EC%9D%BC%EC%83%81/id6737822930")
        return metaData
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
