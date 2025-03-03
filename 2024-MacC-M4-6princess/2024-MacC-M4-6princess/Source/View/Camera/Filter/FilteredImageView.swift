import SwiftUI
import UIKit
import FirebaseAnalytics

struct FilteredImageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var frameManager: FrameManager
    @FetchRequest(entity: StoreImages.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)])
    private var filterImages: FetchedResults<StoreImages>
    
    @State private var selectedFilter: UUID?
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //            if let selectedFilter = selectedFilter,
                //               let filterImage = filterImages.first(where: { $0.uuid == selectedFilter }),
                //               let uiImage = UIImage(data: (filterImage.image)!) {
                //                Image(uiImage: uiImage)
                //                    .resizable()
                //                    .scaledToFit()
                //                    .frame(height: 300)
                //                    .padding()
                //            }else {
                //                Color.pointPink
                //                    .frame(height: 300)
                //            }
                
                FilterCollectionViewRepresentable(
                    filterImages: Array(filterImages),
                    selectedFilter: $selectedFilter, viewModel: viewModel
                )
                .frame(height: 100)
                
                // 투명한 탭 영역
                Color.clear
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                
                Button {
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
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 6)
                .allowsHitTesting(true)
                .alert("프레임이 선택되지 않았습니다. 프레임을 선택해주세요!", isPresented: $viewModel.isShowAlert) {
                    Button("닫기", role: .cancel) { }
                } message: {
                    Text("")
                }
                
                
            }
        }
        .frame(height: 124)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.cameraManager.startSession()
            }
        }
        .onDisappear {
            viewModel.cameraManager.stopSession()
        }
        .onChange(of: filterImages.count) { _ in
            reloadFilterImages()
        }
    }
    private func reloadFilterImages() {
        // FetchRequest 갱신
        for image in filterImages {
            viewContext.refresh(image, mergeChanges: true)
        }
    }
}
