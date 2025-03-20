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
    @EnvironmentObject var naviManager: NavigationManager
    @EnvironmentObject var frameManager: FrameManager
    @EnvironmentObject var imageModel: ImageListModel
    @EnvironmentObject var layerListViewModel: LayerListViewModel
    @StateObject var viewModel = CameraViewModel()
    @StateObject var motionManager = MotionManager()
    //    @StateObject var frameManager = FrameManager()
    
    private var cameraPreview: some View  {
        GeometryReader { geo in
            CameraPreview(viewModel: viewModel)
                .frame(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                .onAppear {
                    viewModel.frameSize.size = CGSize(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                }
            //            Group{
            //                if let image = frameManager.resultImage {
            //                    Image(uiImage: image)
            //                        .resizable()
            //                        .aspectRatio(contentMode: .fill)
            //                }
            //            }
            if let selectedFilterID = frameManager.selectedFrame {
                FilteredCoreDataImageView(filterID: selectedFilterID)
                    .frame(width: geo.size.width, height: geo.size.width * viewModel.frameRatio)
                    .allowsHitTesting(false)
            }
            
        }
    }
    
    var body: some View {
        
        ZStack{
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 46) // TopView 높이만큼 여백 확보
                
                ZStack{
                    if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
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
                    }
                    else{
                        cameraPreview
                            .frame(width: (UIScreen.main.bounds.height - 200) / viewModel.frameRatio,
                                    height: (UIScreen.main.bounds.height - 200) )
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
                    }
                       
                    //                        FilteredImageView()
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
                    .environmentObject(imageModel)
                    .environmentObject(layerListViewModel)
            }
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
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(title: Text("오류 발생"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            // 프레임 크기 설정
            viewModel.cameraManager.checkVideoAuthorizaion()
            viewModel.cameraManager.startSession()
            viewModel.isTakePic = false
//            frameManager.selectedFrame = nil
            Analytics.logEvent("A1_카메라", parameters: nil)
        }
        
    }
    // 아이패드로 추정하는 기준
    func isActuallyiPad() -> Bool {
        let size = UIScreen.main.bounds.size
        let longerSide = max(size.width, size.height)
        return longerSide > 1000
    }
    
    
}
