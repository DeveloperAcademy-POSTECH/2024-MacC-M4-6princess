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
    @ObservedObject private var viewModel = CameraViewModel()
    @StateObject var motionManager = MotionManager()
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
        NavigationStack {
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
                                                .padding(.bottom, 35)
                                                .padding(.leading, -8)
                                            
                                        }
                                        .onTapGesture {
                                            viewModel.firstTime = true
                                            viewModel.isFrameSelect.toggle()
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
            .persistentSystemOverlays(.hidden)
            .onAppear {
                viewModel.cameraManager.startSession()
                motionManager.startDeviceMotionUpdates()
//                viewModel.isFrameSelect = false
            }
            .fullScreenCover(isPresented: $viewModel.isFrameSelect) {
                CameraFrameSelectView(viewModel: viewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                
            }
//            .onChange(of: viewModel.isFrameSelect) { newValue in
//                if !newValue {  // 프레임 선택 뷰가 닫힐 때
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  // 약간의 지연을 주어 뷰 전환이 완료된 후 실행
//                        viewModel.cameraManager.stopSession()  // 기존 세션을 중지
//                        viewModel.cameraManager.setUp()        // 새로 설정
//                        viewModel.cameraManager.startSession() // 세션 재시작
//                    }
//                } else {  // 프레임 선택 뷰가 열릴 때
//                    viewModel.cameraManager.stopSession()  // 세션 중지
//                }
//            }
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
            viewModel.cameraManager.checkVideoAuthorizaion()
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
