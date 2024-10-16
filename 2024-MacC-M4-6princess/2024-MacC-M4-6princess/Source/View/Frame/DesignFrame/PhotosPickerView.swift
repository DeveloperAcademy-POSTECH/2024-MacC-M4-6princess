import SwiftUI
import PhotosUI

struct PhotosPickerView: View {
    @State private var selectedItem: [PhotosPickerItem] = []
    @State private var item: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage? = nil
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(selection: $selectedItem, maxSelectionCount: 1, matching: .images) {
                }
                .photosPickerAccessoryVisibility(.visible)
                .photosPickerDisabledCapabilities([.search, .collectionNavigation, .stagingArea])
                .photosPickerStyle(.inline)
            }
            .navigationBarBackButtonHidden()
            .onChange(of: selectedItem) {
                
                Task {
                    if let data = try? await selectedItem[0].loadTransferable(type: Data.self) {
                        pickedImage = UIImage(data:data)
                        if pickedImage != nil {
                            isPresented = true
                        }
                    }
                    
                }
            }
            .navigationDestination(isPresented: $isPresented) {
                DFFrameEditView(pickedImage: $pickedImage)
            }
        }
    }
}

#Preview {
    PhotosPickerView()
}
