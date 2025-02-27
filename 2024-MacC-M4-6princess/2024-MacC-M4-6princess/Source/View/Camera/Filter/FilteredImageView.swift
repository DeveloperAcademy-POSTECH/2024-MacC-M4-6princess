import SwiftUI
import UIKit

struct FilteredImageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: StoreImages.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \StoreImages.order, ascending: true)])
    private var filterImages: FetchedResults<StoreImages>
    
    @State private var selectedFilter: UUID?
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        VStack {
            if let selectedFilter = selectedFilter,
               let filterImage = filterImages.first(where: { $0.uuid == selectedFilter }),
               let uiImage = UIImage(data: (filterImage.image)!) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
            }else {
                Color.pointPink
                    .frame(height: 300)
            }
            
            FilterCollectionViewRepresentable(
                filterImages: Array(filterImages),
                selectedFilter: $selectedFilter, viewModel: viewModel
            )
            .frame(height: 100)
        }
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
