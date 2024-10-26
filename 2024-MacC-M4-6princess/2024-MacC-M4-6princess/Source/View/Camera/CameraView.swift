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
    @StateObject var viewModel = CameraViewModel() //viewmodel 가져옴
    @StateObject var motionManager = MotionViewModel()
    @State var frameImage: UIImage?
    @State var delayTime: TimeInterval = 0.0
    @State var isPushedTimer = 0
    @State var isTakePic = false
    @State var isFrameSelect = false
    @State var isFullScreenPop: Bool = false
    @State var selectedFrame: UUID? = nil
    @State var isFrameSelected: Bool = false
    @State private var showAlert = false
    @State var idolImg = UIImage(named: "Felix")!
    //    @AppStorage("openFirstTime") private var firstTime = false
    @State var firstTime = false
    var defaultImg: UIImage = UIImage(named: "6princess")!
    @State var frameRatio:CGFloat = 4/3
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack{
                    HStack(alignment: .bottom) {
                        Spacer()
                        VStack {
                            Spacer()
                            Button {
                                viewModel.changeCamera()
                            } label: {
                                Image("cameraReverseIcon")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                    .animation(.easeInOut, value: motionManager.currentOrientation)
                                
                            }.padding(.trailing, 20)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 82)
                    .background(.white)
                    ZStack{
                        CameraPreview(camera: viewModel)
                            .frame(width: viewModel.frameSize.width,height: viewModel.frameSize.height)
                            .ignoresSafeArea(.all, edges: .all)
                        Group{
                            if let image = frameImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .onAppear {
                            loadSelectedFrame()
                        }
                        .onChange(of: selectedFrame) {
                            loadSelectedFrame()
                        }
                    }
                    VStack{
                        HStack (alignment: .center){
                            
                            //프레임 불러오기 버튼
                            Button {
                                isFrameSelect = true
                            } label: {
                                VStack(alignment: .center, spacing: 4) {
                                    Image("frameLoad")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                        .animation(.easeInOut, value: motionManager.currentOrientation)
                                    Text("불러오기")
                                        .font(Font.custom("SF Pro", size: 13))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                                }
                            }
                            
                            Spacer()
                            
                            //셔터 버튼
                            Button {
                                if isFrameSelected {
                                    self.isTakePic = true
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
                                        viewModel.takePic()
                                    }
                                } else {
                                    showAlert = true
                                }
                            } label: {
                                Image("shutterImage")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(motionManager.rotationAngle(for: motionManager.currentOrientation))
                                    .animation(.easeInOut, value: motionManager.currentOrientation)
                            }
                            .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $showAlert) {
                                Button("닫기", role: .cancel) { }
                            } message: {
                                Text("")
                            }
                            
                            Spacer()
                            
                            //타이머 설정 버튼
                            CameraTimerView(delayTime: $delayTime, isPushed: $isPushedTimer)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    .frame(width: UIScreen.main.bounds.width, height: 132)
                    .background(.white)
                }
                //v end
                //처음 실행했을 때
                if !firstTime  {
                    CameraOnboardingView(firstTime: $firstTime)
                        .ignoresSafeArea(.all, edges: .all)
                        .zIndex(1)
                }
                if delayTime != 0 && isTakePic == true {
                    CameraTimerSecondsView(delayTime: $delayTime, isTakePic: $isTakePic)
                        .ignoresSafeArea(.all, edges: .all)
                }
                
                
                
            }
            .persistentSystemOverlays(.hidden)
            .onAppear(perform: {
                viewModel.checkVideoAuthorizaion()
                motionManager.startDeviceMotionUpdates()
                //                    DispatchQueue.main.async {
                //                        camera.session.startRunning()
                //                    }
            })
            .fullScreenCover(isPresented: $isFrameSelect) {
                CameraFrameSelectView(isFullScreenPop: $isFullScreenPop, selectedFrame: $selectedFrame, isFrameSelected: $isFrameSelected)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                
            }
            .statusBar(hidden: true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.nextView) {
                if let takenImg = viewModel.takenImg,let frameImg = frameImage{
                    IEIntroView(bg: takenImg, idol: frameImg)
                }
                else{
                    IEIntroView(bg: defaultImg,idol: idolImg)
                    
                }
            }
            
        }
        .onAppear{
            viewModel.frameSize.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 229)
        }
        
    }
    //이미지 렌더링해서 불러오기
    private func loadSelectedFrame() {
        guard let frameId = selectedFrame else {
            frameImage = nil
            return
        }
        
        let fetchRequest: NSFetchRequest<StoreImages> = StoreImages.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", frameId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let storedImage = results.first, let imageData = storedImage.image {
                frameImage = UIImage(data: imageData)
            } else {
                frameImage = nil
            }
        } catch {
            print("Error fetching frame: \(error)")
            frameImage = nil
        }
    }
}
