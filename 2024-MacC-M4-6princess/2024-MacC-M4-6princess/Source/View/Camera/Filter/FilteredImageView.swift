import SwiftUI
import UIKit
import FirebaseAnalytics

struct FilteredImageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var frameManager: FrameManager
    @FetchRequest(entity: StoreImages.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.createdDate, ascending: true)])
    var filterImages: FetchedResults<StoreImages>
    
    //    @State var selectedFilter: UUID?
    
    @StateObject var viewModel: CameraViewModel
    @State private var refreshID = UUID() // 강제 새로고침을 위한 ID
    
    var body: some View {
        if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
            GeometryReader { geometry in
                ZStack {
                    FilterCollectionViewRepresentable(
                        viewModel: viewModel
                    )
                    .frame(height: 100)
                    .id(refreshID)
                    .onAppear {
                        refreshID = UUID()
                    }
                    
                    
                    // 투명한 탭 영역
                    Color.clear
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                    
                    Button {
                        guard let selectedFrame = frameManager.selectedFrame else {
                            viewModel.isShowAlert = true
                            return
                        }
                        
                        if frameManager.resultImage != nil {
                            self.viewModel.isTakePic = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + viewModel.delayTime) {
                                viewModel.takePic()
                                viewModel.cameraManager.stopSession()
                                Analytics.logEvent("A1_셔터버튼눌림", parameters: nil)
                            }
                        } else {
                            viewModel.isShowAlert = true
                        }
                    } label: {
                        Image("shutterImage")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $viewModel.isShowAlert) {
                        Button("닫기", role: .cancel) { }
                    } message: {
                        Text("")
                    }

                    
                    
                }
            }
//            .id(refreshID) //뷰 강제 업데이트
            .frame(height: 124)
            .onAppear {
//                DispatchQueue.main.async {
                DispatchQueue.global(qos: .userInitiated).async {
                    //보라색 무시해주세요
                    viewModel.cameraManager.session.startRunning()
                    DispatchQueue.main.async {
                             reloadFilterImages()
                             // refreshID = UUID()
                         }
//                    refreshID = UUID()
                }
            }
            .onDisappear {
                viewModel.cameraManager.stopSession()
                reloadFilterImages()
            }
            .onChange(of: frameManager.resultImage) { oldValue, newValue in
                reloadFilterImages()
//                refreshID = UUID()
                //왜 안될까...
            }
        }
        else{
            filteredIPad
        }
    }
    func reloadFilterImages() {
        // FetchRequest 갱신
        for image in filterImages {
            viewContext.refresh(image, mergeChanges: true)
        }
    }
}
