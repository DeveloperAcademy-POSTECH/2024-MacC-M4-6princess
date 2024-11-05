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
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = CameraViewModel()
    @StateObject var motionManager = MotionManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack{
                    CameraTopView(viewModel: viewModel)
                    ZStack{
                        CameraPreview(viewModel: viewModel)
                            .frame(width: viewModel.frameSize.width,height: viewModel.frameSize.height)
                            .ignoresSafeArea(.all, edges: .all)
                        Group{
                            if let image = viewModel.frameImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .onAppear {
                            loadSelectedFrame()
                        }
                        .onChange(of: viewModel.selectedFrame) {
                            loadSelectedFrame()
                        }
                    }
                    CameraBottomView(viewModel: viewModel)
                }
                //v end
                //처음 실행했을 때
                if !viewModel.firstTime  {
                    CameraOnboardingView(viewModel: viewModel)
                        .ignoresSafeArea(.all, edges: .all)
                        .zIndex(1)
                }
                if viewModel.delayTime != 0 && viewModel.isTakePic == true {
                    CameraTimerSecondsView(delayTime: $viewModel.delayTime, isTakePic: $viewModel.isTakePic)
                        .ignoresSafeArea(.all, edges: .all)
                }
                
                
                
            }
            .persistentSystemOverlays(.hidden)
            .onAppear(perform: {
                viewModel.cameraManager.checkVideoAuthorizaion()
                motionManager.startDeviceMotionUpdates()
            })
            .fullScreenCover(isPresented: $viewModel.isFrameSelect) {
                CameraFrameSelectView(isFullScreenPop: $viewModel.isFullScreenPop, selectedFrame: $viewModel.selectedFrame, isFrameSelected: $viewModel.isFrameSelected)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                
            }
            .statusBar(hidden: true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.nextView) {
                if let takenImg = viewModel.takenImg,let frameImg = viewModel.frameImage{
                    IEIntroView(bg: takenImg, idol: frameImg)
                }
                else{
                    IEIntroView(bg: viewModel.defaultImg,idol: viewModel.idolImg)
                    
                }
            }
            
        }
        .onAppear {
            // 프레임 크기 설정
            viewModel.frameSize.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229)
//            let screenWidth = UIScreen.main.bounds.width
//            let desiredHeight = screenWidth * (4.0/3.0)
//            viewModel.frameSize = CGRect(
//                x: 0,
//                y: (UIScreen.main.bounds.height - desiredHeight) / 2,
//                width: screenWidth,
//                height: desiredHeight
//            )
        }
        
    }
    //이미지 렌더링해서 불러오기
    private func loadSelectedFrame() {
        guard let frameId = viewModel.selectedFrame else {
            viewModel.frameImage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", frameId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let storedImage = results.first, let imageData = storedImage.image {
                viewModel.frameImage = UIImage(data: imageData)
            } else {
                viewModel.frameImage = nil
            }
        } catch {
            print("Error fetching frame: \(error)")
            viewModel.frameImage = nil
        }
    }
}
