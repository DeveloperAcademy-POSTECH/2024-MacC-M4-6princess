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
                FilterCollectionViewRepresentable(
                    viewModel: viewModel
                )
                .frame(height: 100)
                .id(refreshID)
                .onAppear {
                    refreshID = UUID()
                }
            }
            .frame(height: 124)
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    viewModel.cameraManager.session.startRunning()
                    DispatchQueue.main.async {
                        reloadFilterImages()
                    }
                }
            }
            .onDisappear {
                viewModel.cameraManager.stopSession()
                reloadFilterImages()
            }
            .onChange(of: frameManager.resultImage) { oldValue, newValue in
                reloadFilterImages()
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
