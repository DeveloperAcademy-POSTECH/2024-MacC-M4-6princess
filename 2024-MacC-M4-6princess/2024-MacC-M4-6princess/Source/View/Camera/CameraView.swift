//
//  CameraView.swift
//  2024-MacC-M4-6princess
//
//  Created by 김이예은 on 9/30/24.
//

import SwiftUI
import AVFoundation
import CoreData
import FirebaseAnalytics

struct CameraView: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel = CameraViewModel()
    @StateObject var motionManager = MotionManager()
    @StateObject var naviManager = NavigationManager()
    @StateObject var frameManager = FrameManager()
    
    private var cameraPreview: some View  {
        GeometryReader { geo in
            CameraPreview(viewModel: viewModel)
                .frame(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                .onAppear {
                    viewModel.frameSize.size = CGSize(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                }
            Group{
                if let image = frameManager.resultImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .allowsHitTesting(false)
        }
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack{
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 94) // TopView 높이만큼 여백 확보
                    
                    cameraPreview
                        .frame(width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.width * viewModel.frameRatio)
                        .gesture(MagnificationGesture()
                            .onChanged { val in
                                viewModel.zoom(factor: val)
                            }
                            .onEnded { _ in
                                viewModel.zoomInitialize()
                            })
                        .onAppear {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                viewModel.showOrientationAlert = true
                            }
                        }
                    
                    Spacer()
                }
                VStack {
                    CameraTopView(viewModel: viewModel)
                    Spacer()
                    CamZoomButtonView(viewModel: viewModel, motionManager: motionManager)
                        .mask(Rectangle().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 4/3))
                    CameraBottomView(viewModel: viewModel)
                        .environmentObject(naviManager)
                        .environmentObject(frameManager)
                }
                //v end
                //처음 실행했을 때 - 온보딩 합침
                if !viewModel.firstTime {
                    BGView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    OnboardingView(viewModel: viewModel)
                    
                }
                //                if !viewModel.firstTime  {
                //                    VStack {
                //                        ZStack {
                //                            Text("최애와 사진을 찍기 위해\n프레임 선택하기")
                //                                .font(.system(size: 17))
                //                                .multilineTextAlignment(.center)
                //                                .foregroundColor(.white)
                //                            VStack(alignment: .leading){
                //                                Spacer()
                //
                //                                HStack {
                //                                    VStack {
                //                                        Image("handPointer")
                //                                            .resizable()
                //                                            .frame(width: 114, height: 114)
                //                                            .padding(.bottom, 20)
                //
                //                                        if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
                //                                            VStack {
                //                                                ZStack {
                //                                                    Rectangle()
                //                                                        .cornerRadius(5)
                //                                                        .frame(width: 40, height: 40)
                //                                                        .foregroundColor(.pointPink)
                //
                //                                                    Image("frameLoadWhite")
                //                                                        .resizable()
                //                                                        .frame(width: 40, height: 40)
                //                                                }
                //                                                .padding(.bottom, 4)
                //                                                .padding(.leading, -8)
                //
                //                                                Text("불러오기")
                //                                                    .font(.system(size: 13))
                //                                                    .multilineTextAlignment(.center)
                //                                                    .foregroundColor(.white)
                //                                                    .padding(.bottom, 60)
                //                                                    .padding(.leading, -8)
                //
                //                                            }
                //                                            .onTapGesture {
                //                                                viewModel.firstTime = true
                ////                                                viewModel.isShowMFView.toggle()
                //                                                frameManager.showMFView = true
                //                                            }
                //                                        }
                //                                        else{
                //                                            VStack {
                //                                                ZStack {
                //                                                    Rectangle()
                //                                                        .cornerRadius(5)
                //                                                        .frame(width: 40, height: 40)
                //                                                        .foregroundColor(.pointPink)
                //
                //                                                    Image("frameLoadWhite")
                //                                                        .resizable()
                //                                                        .frame(width: 40, height: 40)
                //                                                }
                //                                                .padding(.bottom, 4)
                //                                                .padding(.leading, -8)
                //
                //                                                Text("불러오기")
                //                                                    .font(.system(size: 13))
                //                                                    .multilineTextAlignment(.center)
                //                                                    .foregroundColor(.white)
                //                                                    .padding(.bottom, 20)
                //                                                    .padding(.leading, -8)
                //
                //                                            }
                //                                            .onTapGesture {
                //                                                viewModel.firstTime = true
                ////                                                viewModel.isShowMFView.toggle()
                //                                                frameManager.showMFView = true
                //                                            }
                //                                        }
                //
                //                                    }
                //                                    .padding(.leading, -10)
                //                                    Spacer()
                //                                }
                //                            }
                //                        }
                //
                //
                //                    }
                //                    .ignoresSafeArea(.all)
                //                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                //                    .background(.black)
                //                    .opacity(0.8)
                //
                //                }
                if viewModel.delayTime != 0 && viewModel.isTakePic == true {
                    CameraTimerSecondsView(viewModel: viewModel)
                        .ignoresSafeArea(.all, edges: .all)
                }
            }
            .onChange(of: frameManager.isFrameLoading) { newValue in
                if newValue {
                    loadSelectedFrame()
                    frameManager.isFrameLoading = false
                }
            }
            .alert("세로 고정 권장", isPresented: $viewModel.showOrientationAlert) {
                            Button("확인") { }
            } message: {
                Text("이 앱은 세로 화면에서 더 좋은 경험을 제공합니다.\n세로 화면 고정을 활성화해주세요.")
            }
            .persistentSystemOverlays(.hidden)
            .onAppear {
                motionManager.startDeviceMotionUpdates()
                if isActuallyiPad() {
                    viewModel.showOrientationAlert = true
                }
                
                //                viewModel.frameImage = frameImage
            }
            .alert("세로 화면 고정 권장", isPresented: $viewModel.showOrientationAlert) {
                Button("확인") { }
            } message: {
                Text("이 앱은 세로 화면에서 더 좋은 경험을 제공합니다.\n세로 화면 고정을 활성화해주세요.")
            }
            .fullScreenCover(isPresented: $frameManager.showMFView) {
                MFView(viewModel: MFViewModel(context: viewContext, frameManager: frameManager))
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .environmentObject(naviManager)
                    .environmentObject(frameManager)
            }
            .statusBar(hidden: true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.nextView) {
                if let takenImg = viewModel.takenImg, let frameImg = frameManager.resultImage {
                    IOView(bg: takenImg, idol: frameImg, motionManager: motionManager)
                } else {
                    EmptyView()
                        .onAppear {
                            viewModel.errorMessage = "프레임이 없습니다. 다시 촬영해주세요."
                            viewModel.showErrorAlert = true
                        }
                }
            }
            
            
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("오류 발생"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            // 프레임 크기 설정
            viewModel.cameraManager.checkVideoAuthorizaion()
            viewModel.cameraManager.startSession()
            Analytics.logEvent("A1_카메라", parameters: nil)
        }
        
    }
    // 아이패드로 추정하는 기준
    func isActuallyiPad() -> Bool {
        let size = UIScreen.main.bounds.size
        let longerSide = max(size.width, size.height)
        return longerSide > 1000
    }
    
    struct BGView: View {
        var body: some View {
            Color.bgGray
        }
    }
}
