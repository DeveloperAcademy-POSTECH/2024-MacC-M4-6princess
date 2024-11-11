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
    @Binding var frameImage: UIImage?
    
    init(frameImage: Binding<UIImage?> = .constant(nil)) {
        _frameImage = frameImage
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        CameraTopView(viewModel: viewModel)
                        Spacer()
                        ZStack {
                            CameraPreview(viewModel: viewModel)
                                .frame(width: geometry.size.width)
                            Group {
                                if let image = viewModel.frameImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                            }
                        }
                        Spacer()
                        CameraBottomView(viewModel: viewModel)
                    }
                    
                    // 온보딩 뷰
                    if !viewModel.firstTime {
                        VStack {
                            ZStack {
                                Text("최애와 사진을 찍기 위해\n프레임 선택하기")
                                    .font(.system(size: 17))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading) {
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
                                                    .padding(.bottom, 50)
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
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(.black)
                        .opacity(0.8)
                    }
                    
                    if viewModel.delayTime != 0 && viewModel.isTakePic == true {
                        CameraTimerSecondsView(delayTime: $viewModel.delayTime,
                                             isTakePic: $viewModel.isTakePic)
                            .ignoresSafeArea(.all, edges: .all)
                    }
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
                if let takenImg = viewModel.takenImg, let frameImg = viewModel.frameImage {
                    IEIntroView(bg: takenImg, idol: frameImg)
                }
            }
        }
        .onAppear {
            viewModel.cameraManager.checkVideoAuthorizaion()
            viewModel.cameraManager.startSession()
        }
    }
    
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
