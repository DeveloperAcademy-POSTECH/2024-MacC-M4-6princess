import SwiftUI
import UIKit
import FirebaseAnalytics
import CoreData

struct FilteredImageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var frameManager: FrameManager
    @FetchRequest(
        entity: StoreImages.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)] // 빈 배열 전달
    )

    var filterImages: FetchedResults<StoreImages>
    
    @StateObject var viewModel: CameraViewModel
    
    var body: some View {
        if UIScreen.main.bounds.height/UIScreen.main.bounds.width > 2.0 {
            GeometryReader { geometry in
                ZStack {
                    FilterCollectionViewRepresentable(
                        viewModel: viewModel
                    )
                    .frame(height: 100)
                    
                    Color.clear
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                    
                    Button {
                        if frameManager.resultImage != nil {
                            self.viewModel.isTakePic = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.delayTime) {
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
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                    .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $viewModel.isShowAlert) {
                        Button("닫기", role: .cancel) { }
                    }
                }
            }
            .frame(height: 124)
            .onAppear {
                DispatchQueue.main.async {
                    viewModel.cameraManager.session.startRunning()
                    reloadFilterImages()
                }
            }
            .onDisappear {
                viewModel.cameraManager.stopSession()
            }
            .onChange(of: frameManager.resultImage) { _, _ in
                reloadFilterImages()
            }
        } else {
            filteredIPad // iPad 레이아웃 구현부 (생략)
        }
    }
    
    func reloadFilterImages() {
        
        for image in filterImages {
            viewContext.refresh(image, mergeChanges: true)
        }
    }
}

