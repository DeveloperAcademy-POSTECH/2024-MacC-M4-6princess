//
//  CameraView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation
import CoreData

struct CameraView: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel = CameraViewModel()
    @StateObject var motionManager = MotionManager()
    @State private var path: NavigationPath = NavigationPath()
    @Binding var frameImage: UIImage?  // 옵셔널 바인딩
    
    init(frameImage: Binding<UIImage?> = .constant(nil)) {  // 기본값 설정
        _frameImage = frameImage
    }
    
    //TODO: 바인딩 변수로 방금 만든 frame 불러오기
    
    
    private var cameraPreview: some View  {
        
        GeometryReader { geo in
            CameraPreview(viewModel: viewModel)
                .frame(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                .onAppear {
                    viewModel.frameSize.size = CGSize(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                }
        }
    }
    
    var body: some View {
        
        NavigationStack(path: $path) {
            ZStack {
                VStack{
                    CameraTopView(viewModel: viewModel)
                    ZStack{
                        cameraPreview
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * viewModel.frameRatio)
                        Group{
                            if let image = viewModel.frameImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                    }
                    .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                    CameraBottomView(viewModel: viewModel)
                }
                //v end
                //처음 실행했을 때 - 온보딩 합침
                if !viewModel.firstTime  {
                    VStack {
                        ZStack {
                            Text("최애와 사진을 찍기 위해\n프레임 선택하기")
                                .font(.system(size: 17))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            VStack(alignment: .leading){
                                Spacer()
                                
                                HStack {
                                    VStack {
                                        Image("handPointer")
                                            .resizable()
                                            .frame(width: 114, height: 114)
                                            .padding(.bottom, 20)
                                        
                                        if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
                                            VStack {
                                                ZStack {
                                                    Rectangle()
                                                        .cornerRadius(5)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.pointPink)
                                                    
                                                    Image("frameLoadWhite")
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                }
                                                .padding(.bottom, 4)
                                                .padding(.leading, -8)
                                                
                                                Text("불러오기")
                                                    .font(.system(size: 13))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                                    .padding(.bottom, 60)
                                                    .padding(.leading, -8)
                                                
                                            }
                                            .onTapGesture {
                                                viewModel.firstTime = true
                                                viewModel.isFrameSelect.toggle()
                                            }
                                        }
                                        else{
                                            VStack {
                                                ZStack {
                                                    Rectangle()
                                                        .cornerRadius(5)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.pointPink)
                                                    
                                                    Image("frameLoadWhite")
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                }
                                                .padding(.bottom, 4)
                                                .padding(.leading, -8)
                                                
                                                Text("불러오기")
                                                    .font(.system(size: 13))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                                    .padding(.bottom, 20)
                                                    .padding(.leading, -8)
                                                
                                            }
                                            .onTapGesture {
                                                viewModel.firstTime = true
                                                viewModel.isFrameSelect.toggle()
                                            }
                                        }
                                       
                                    }
                                    .padding(.leading, -10)
                                    Spacer()
                                }
                            }
                        }
                        
                        
                    }
                    .ignoresSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .background(.black)
                    .opacity(0.8)
                    
                }
                if viewModel.delayTime != 0 && viewModel.isTakePic == true {
                    CameraTimerSecondsView(delayTime: $viewModel.delayTime, isTakePic: $viewModel.isTakePic)
                        .ignoresSafeArea(.all, edges: .all)
                }
            }
            .onChange(of: viewModel.isFrameLoading) { newValue in
                if newValue {
                    loadSelectedFrame()
                    viewModel.isFrameLoading = false
                }
            }
            .persistentSystemOverlays(.hidden)
            .onAppear {
                motionManager.startDeviceMotionUpdates()
                viewModel.frameImage = frameImage
                if frameImage != nil {
                    viewModel.isFrameSelected = true
                }
            }
            .fullScreenCover(isPresented: $viewModel.isFrameSelect) {
                CameraFrameSelectView(viewModel: viewModel, frameImage: $frameImage)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                
            }
            .statusBar(hidden: true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.nextView) {
                if let takenImg = viewModel.takenImg,let frameImg = viewModel.frameImage{
                    IEIntroView(bg: takenImg, idol: frameImg)
                }
                
            }
            
        }
        .onAppear {
            // 프레임 크기 설정
            viewModel.cameraManager.checkVideoAuthorizaion()
            viewModel.cameraManager.startSession()
            
        }
        
    }
    
}
